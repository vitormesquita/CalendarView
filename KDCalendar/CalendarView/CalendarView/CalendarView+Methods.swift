
//
//  CalendarView+Methods.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 06/02/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

extension CalendarView {
    
    /**
     Rebuild date with first day of month
     - parameters:
        - date: Date to extract month and rebuild with first day
     */
    internal func buildFirstDayOfMonthFrom(date: Date) -> Date? {
        var dateComponents = calendar.dateComponents([.era, .year, .month], from: date)
        dateComponents.day = 1
        return calendar.date(from: dateComponents)
    }
    
    /**
     Rebuild date with last day of month
     - parameters:
        - date: Date to extract month and rebuild with end day
     */
    internal func buildLastDayOfMonthFrom(date: Date) -> Date? {
        var dateComponents = calendar.dateComponents([.era, .year, .month], from: date)
        let range = calendar.range(of: .day, in: .month, for: date)
        dateComponents.day = range?.count
        return calendar.date(from: dateComponents)
    }
    
    /**
     Generate indexPath from today Date if it's contains in range of dates
     */
    internal func getTodayIndexPath(startDate: Date, endDate: Date) -> IndexPath? {
        let today = Date()
        
        guard (startDate ... endDate).contains(today)  else { return nil }
        
        let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: startDate, to: today)
        return IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
    }
    
    /**
     Generate and increment `monthInfoForSection` variable
     */
    internal func buildMonthInfoBy(section: Int) -> Bool {
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section
        
        let correctMonthForSectionDate = self.calendar.date(byAdding: monthOffsetComponents, to: cacheOfStartOfMonth)
        
        guard let date = correctMonthForSectionDate, let info = self.getMonthInfo(for: date) else { return false }
        
        self.monthInfoForSection[section] = info
        return true
    }
    
    /**
     Get week day to first day and total of days in month
     */
    internal func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        
        var firstWeekdayIndex = self.calendar.component(.weekday, from: date)
        firstWeekdayIndex = (firstWeekdayIndex + 6) % 7

        guard let rangeOfDaysInMonth = self.calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        return (firstDay: firstWeekdayIndex, daysTotal: rangeOfDaysInMonth.count)
    }
}
