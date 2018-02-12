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
    
    internal var displayDate: Date?
    internal var todayIndexPath: IndexPath?
    
    internal var selectedIndexPaths = [IndexPath]()
    
    internal var monthInfoForSection = [Int: (firstDay: Int, daysTotal: Int)]()
    internal var eventsByIndexPath = [IndexPath: [CalendarEvent]]()
    
    // MARK: - Internal lazys
    
    internal lazy var calendar : Calendar = {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        return gregorian
    }()
    
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
    
    // MARK: Private
    
    private var headerConstraints: [NSLayoutConstraint] = []
    private var collectionConstraints: [NSLayoutConstraint] = []
    
    // MARK: UIView methods
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
        flowLayout.invalidateLayout()
        
        if let displayDate = displayDate {
            setDisplayDate(displayDate)
        }
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
    
    // MARK: - Layout
    private func autoLayout() {
        NSLayoutConstraint.deactivate(headerConstraints)
        NSLayoutConstraint.deactivate(collectionConstraints)
        
        headerConstraints = [headerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                                 headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                 headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                 headerView.heightAnchor.constraint(equalToConstant: CalendarView.Style.headerHeight)]
        
        collectionConstraints = [collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
                                     collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(headerConstraints)
        NSLayoutConstraint.activate(collectionConstraints)
    }
    
    private func cellSize() -> CGSize {
        return CGSize(width: bounds.size.width/numberOfDaysInWeek, height: (bounds.size.height - CalendarView.Style.headerHeight)/maxNumberOfWeeks)
    }
}

// MARK: - Public methods
extension CalendarView {
    
    
    /// Reload all components in collection view
    public func reloadData() {
        self.collectionView.reloadData()
    }
    
    /// Selected date and scroll at correspondent month
    public func selectDate(_ date: Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView(collectionView, didSelectItemAt: indexPath)
        
        var centeredIndexPath = indexPath
        centeredIndexPath.item = 17 //work around center item of section
        self.collectionView.selectItem(at: centeredIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /// Deselect date from a date
    public func deselectDate(_ date: Date) {
        guard let indexPath = self.indexPathForDate(date) else { return }
        self.collectionView.deselectItem(at: indexPath, animated: false)
        self.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    /// Scroll to next month by current
    public func goToNextMonth() {
        goToMonthWithOffet(1)
    }
    
    
    /// Scroll to previus month by current
    public func goToPreviousMonth() {
        goToMonthWithOffet(-1)
    }
}
