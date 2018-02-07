/*
 * CalendarView.swift
 * Created by Michael Michailidis on 02/04/2015.
 * http://blog.karmadust.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import EventKit

// MARK: - Constants
internal let maxNumberOfWeeks: CGFloat = 6
internal let numberOfDaysInWeek: CGFloat = 7
internal let cellReuseIdentifier = "CalendarDayCell"

public class CalendarView: UIView {
    
    internal var displayDate: Date?
    internal var todayIndexPath: IndexPath?
    
    internal var selectedIndexPaths = [IndexPath]()
    
    internal var monthInfoForSection = [Int: (firstDay: Int, daysTotal: Int)]()
    internal var eventsByIndexPath = [IndexPath: [CalendarEvent]]()
    
    // MARK: - Public
    
    public var multipleSelectionEnable = true
    public var delegate: CalendarViewDelegate?
    
    public var direction: UICollectionViewScrollDirection = .horizontal {
        didSet {
            flowLayout.scrollDirection = direction
            collectionView.reloadData()
        }
    }
    
    public var startDate = Date() {
        didSet {
            cacheOfStartOfMonth = buildFirstDayOfMonthFrom(date: startDate)!
            collectionView.reloadData()
        }
    }
    
    public var endDate = Date() {
        didSet {
            cacheOfEndOfMonth = buildLastDayOfMonthFrom(date: endDate)!
            collectionView.reloadData()
        }
    }
    
    public var events: [CalendarEvent] = [] {
        didSet {
            self.eventsByIndexPath.removeAll()
            
            for event in events {
                guard let indexPath = self.indexPathForDate(event.startDate) else { continue }
                
                var eventsForIndexPath = eventsByIndexPath[indexPath] ?? []
                eventsForIndexPath.append(event)
                eventsByIndexPath[indexPath] = eventsForIndexPath
            }
            
            DispatchQueue.main.async { self.collectionView.reloadData() }
        }
    }
    
    // MARK: - Internal
    
    internal var cacheOfEndOfMonth  = Date()
    internal var cacheOfStartOfMonth = Date()
    
    internal lazy var calendar : Calendar = {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        return gregorian
    }()
    
    // MARK: - Views
    
    internal lazy var headerView: CalendarHeaderView = {
        let headerView = CalendarHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    internal lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    internal lazy var flowLayout: CalendarFlowLayout = {
        let flowLayout = CalendarFlowLayout()
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }()
    
    // MARK: Put a name after
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        autoLayout()
        flowLayout.itemSize = self.cellSize()
        resetDisplayDate()
    }
    
    // MARK: Create Subviews
    private func setup() {
        clipsToBounds = true
        
        addSubview(self.headerView)
        addSubview(self.collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        collectionView.register(CalendarDayViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    private func autoLayout() {
        let headerConstraints = [headerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                 headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                 headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                 headerView.heightAnchor.constraint(equalToConstant: CalendarView.Style.headerHeight)]
        
        let collectionConstraints = [collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
                                     collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(headerConstraints)
        NSLayoutConstraint.activate(collectionConstraints)
    }
    
    private func cellSize() -> CGSize {
        return CGSize(width: bounds.size.width/numberOfDaysInWeek, height: (bounds.size.height - CalendarView.Style.headerHeight)/maxNumberOfWeeks)
    }
    
    internal func resetDisplayDate() {
        guard let displayDate = self.displayDate else { return }
        self.collectionView.setContentOffset(self.scrollViewOffset(for: displayDate), animated: false)
    }
}

// MARK: Convertion

extension CalendarView {
    
    func indexPathForDate(_ date : Date) -> IndexPath? {
        
        let distanceFromStartDate = self.calendar.dateComponents([.month, .day], from: self.cacheOfStartOfMonth, to: date)
        
        guard
            let day   = distanceFromStartDate.day,
            let month = distanceFromStartDate.month,
            let (firstDayIndex, _) = monthInfoForSection[month] else { return nil }
        
        return IndexPath(item: day + firstDayIndex, section: month)
    }
    
    func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
        
        let month = indexPath.section
        
        guard let monthInfo = monthInfoForSection[month] else { return nil }
        
        var components      = DateComponents()
        components.month    = month
        components.day      = indexPath.item - monthInfo.firstDay
        
        return self.calendar.date(byAdding: components, to: self.cacheOfStartOfMonth)
    }
    
    func scrollViewOffset(for date: Date) -> CGPoint {
        var point = CGPoint.zero
        
        guard let sections = self.indexPathForDate(date)?.section else { return point }
        
        switch self.direction {
        case .horizontal:   point.x = CGFloat(sections) * self.collectionView.frame.size.width
        case .vertical:     point.y = CGFloat(sections) * self.collectionView.frame.size.height
        }
        
        return point
    }
}

extension CalendarView {
    
    func goToMonthWithOffet(_ offset: Int) {
        
        guard let displayDate = self.displayDate else { return }
        
        var dateComponents = DateComponents()
        dateComponents.month = offset;
        
        guard let newDate = self.calendar.date(byAdding: dateComponents, to: displayDate) else { return }
        self.setDisplayDate(newDate, animated: true)
    }
    
    /**
     - parameters:
        - date: Date to extract month and year to scroll at correct section
        - animated: to handle animation if want
     */
    private func setDisplayDate(_ date : Date, animated: Bool = false) {
        guard (date > startDate) && (date < endDate) else { return }
        self.collectionView.setContentOffset(self.scrollViewOffset(for: date), animated: animated)
        self.displayDateOnHeader(date)
    }
}

// MARK: - Public methods
extension CalendarView {
    
    /**
     Reload all components in collection view
     */
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    /**
     Selected date and scroll at correspondent month
     */
    public func selectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView(collectionView, didSelectItemAt: indexPath)
        
        var centeredIndexPath = indexPath
        centeredIndexPath.item = 17 //work around center item of section
        self.collectionView.selectItem(at: centeredIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /*
     TODO
     */
    public func deselectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.deselectItem(at: indexPath, animated: false)
        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /*
     TODO
     */
    public func goToNextMonth() {
        goToMonthWithOffet(1)
    }
    
    /*
     TODO
     */
    public func goToPreviousMonth() {
        goToMonthWithOffet(-1)
    }
}
