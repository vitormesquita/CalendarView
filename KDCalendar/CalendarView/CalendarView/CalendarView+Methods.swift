
//
//  CalendarView+Methods.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 06/02/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

// MARK: - Build dates from others and increments variables
extension CalendarView {
    
    /// Rebuild date with first day of month
    /// - parameters:
    ///    - date: Date to extract month and rebuild with first day
    ///
    internal func buildFirstDayOfMonthFrom(date: Date) -> Date? {
        var dateComponents = calendar.dateComponents([.era, .year, .month], from: date)
        dateComponents.day = 1
        return calendar.date(from: dateComponents)
    }
    
    /// Rebuild date with last day of month
    /// - parameters:
    ///     - date: Date to extract month and rebuild with end day
    ///
    internal func buildLastDayOfMonthFrom(date: Date) -> Date? {
        var dateComponents = calendar.dateComponents([.era, .year, .month], from: date)
        let range = calendar.range(of: .day, in: .month, for: date)
        dateComponents.day = range?.count
        return calendar.date(from: dateComponents)
    }
    
    /// Generate and increment `monthInfoForSection` variable with section (Month) and informations
    /// - parameters:
    ///      - section: represents uicollectionView section, cause each section is a month
    ///
    internal func buildMonthInfoBy(section: Int) -> Bool {
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section
        
        let correctMonthForSectionDate = self.calendar.date(byAdding: monthOffsetComponents, to: cacheOfStartOfMonth)
        
        guard let date = correctMonthForSectionDate, let info = self.getMonthInfo(for: date) else { return false }
        
        self.monthInfoForSection[section] = info
        return true
    }
    
    /// Get first day and total of days in month from date
    /// - Parameters:
    ///     - date: date to get these informations
    ///
    internal func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        
        var firstWeekdayIndex = self.calendar.component(.weekday, from: date)
        firstWeekdayIndex = (firstWeekdayIndex + 6) % 7
        
        guard let rangeOfDaysInMonth = self.calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        return (firstDay: firstWeekdayIndex, daysTotal: rangeOfDaysInMonth.count)
    }
}

// MARK: Convertions Date to IndexPath and vice-versa
extension CalendarView {
    
    /// Get indexPath matched with date
    /// - Parameters:
    ///    - date: Date to get indexPath in `monthInfoForSection`
    ///
    internal func indexPathForDate(_ date: Date) -> IndexPath? {
        let distanceFromStartDate = self.calendar.dateComponents([.month, .day], from: self.cacheOfStartOfMonth, to: date)
        
        guard let day = distanceFromStartDate.day,
            let month = distanceFromStartDate.month,
            let (firstDayIndex, _) = monthInfoForSection[month] else {
                return nil
        }
        
        return IndexPath(item: day + firstDayIndex, section: month)
    }
    
    /// Generate indexPath from today Date if it's contains in range of dates
    internal func getTodayIndexPath(startDate: Date, endDate: Date) -> IndexPath? {
        let today = Date()
        
        guard (startDate ... endDate).contains(today)  else { return nil }
        
        let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: startDate, to: today)
        return IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
    }
    
    /// Get date from indexPath
    internal func dateFromIndexPath(_ indexPath: IndexPath) -> Date? {
        let month = indexPath.section
        guard let monthInfo = monthInfoForSection[month] else { return nil }
        
        let components = DateComponents(month: month, day: indexPath.item - monthInfo.firstDay)
        return self.calendar.date(byAdding: components, to: self.cacheOfStartOfMonth)
    }
}

// MARK: - Methods to interact with `collectionView`
extension CalendarView {
    
    /// Add offset at `displayDate` to display next or previous month in calendar
    /// - Parameters:
    ///     - offset: represents number of months to go from displayMonth
    ///
    internal func goToMonthWithOffet(_ offset: Int) {
        guard let displayDate = self.displayDate,
            let newDate = self.calendar.date(byAdding: DateComponents(month: offset), to: displayDate) else {
                return
        }
        
        self.setDisplayDate(newDate, animated: true)
    }
    
    /// Scroll to date and update date on Header
    /// - parameters:
    ///      - date: Date to extract month and year to scroll to correct section
    ///      - animated: to handle animation if want
    ///
    internal func setDisplayDate(_ date : Date, animated: Bool = false) {
        guard (date > startDate) && (date < endDate) else { return }
        self.collectionView.setContentOffset(self.scrollViewOffset(for: date), animated: animated)
        self.displayDateOnHeader(date)
    }
    
    /// Get corret point from `collectionView` by date
    /// - Parameters:
    ///    - date: Date to extract month and scroll to correct section
    ///
    internal func scrollViewOffset(for date: Date) -> CGPoint {
        var point = CGPoint.zero
        
        guard let sections = self.indexPathForDate(date)?.section else { return point }
        
        switch self.direction {
        case .horizontal:
            point.x = CGFloat(sections) * self.collectionView.frame.size.width
            
        case .vertical:
            point.y = CGFloat(sections) * self.collectionView.frame.size.height
        }
        
        return point
    }
}

// MARK: - Methods to interact with scroll view
extension CalendarView {
    
    /// Update header and notify `delegate` that scroll to month
    internal func updateAndNotifyScrolling() {
        guard let date = self.dateFromScrollViewPosition() else { return }
        self.displayDateOnHeader(date)
        self.delegate?.calendar(self, didScrollToMonth: date)
    }
    
    /// Get current date from scroll position
    internal func dateFromScrollViewPosition() -> Date? {
        var page: Int = 0
        
        switch direction {
        case .horizontal:
            page = Int(floor(self.collectionView.contentOffset.x / self.collectionView.bounds.size.width))
            
        case .vertical:
            page = Int(floor(self.collectionView.contentOffset.y / self.collectionView.bounds.size.height))
        }
        
        page = page > 0 ? page : 0
        
        var monthsOffsetComponents = DateComponents()
        monthsOffsetComponents.month = page
        
        return self.calendar.date(byAdding: monthsOffsetComponents, to: self.cacheOfStartOfMonth);
    }
    
    /// Update header label with displayed month and year
    internal func displayDateOnHeader(_ date: Date) {
        let month = self.calendar.component(.month, from: date)
        let year = self.calendar.component(.year, from: date)
        
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        
        self.headerView.setHeaderTitle("\(monthName) \(year)")
        self.displayDate = date
    }
}
