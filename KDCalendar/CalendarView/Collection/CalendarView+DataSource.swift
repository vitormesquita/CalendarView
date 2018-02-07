/*
 * CalendarView+DataSource.swift
 * Created by Michael Michailidis on 24/10/2017.
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

extension CalendarView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard self.startDate <= self.endDate else { fatalError("Start date cannot be later than end date.") }
        
        todayIndexPath = getTodayIndexPath(startDate: cacheOfStartOfMonth, endDate: cacheOfEndOfMonth)
        
        // if we are for example on the same month and the difference is 0 we still need 1 to display it
        return self.calendar.dateComponents([.month], from: cacheOfStartOfMonth, to: cacheOfEndOfMonth).month! + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard buildMonthInfoBy(section: section) else { return 0 }
        return Int(numberOfDaysInWeek * maxNumberOfWeeks)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDayViewCell
        
        guard let (firstWeekDayIndex, totalNumberOfDays) = self.monthInfoForSection[indexPath.section] else { return dayCell }
        
        let lastDayIndex = firstWeekDayIndex + totalNumberOfDays
        
        let dayIsOnMonth = (firstWeekDayIndex..<lastDayIndex).contains(indexPath.item) // item within range from first to last day
        dayCell.isHidden = !dayIsOnMonth
        
        if dayIsOnMonth {
            
            let day = (indexPath.item - firstWeekDayIndex) + 1
            dayCell.populateWith(day: day)
            
            if selectedIndexPaths.contains(indexPath) {
                dayCell.isSelectedCell()
                
            } else if indexPath.equals(todayIndexPath, extraItem: firstWeekDayIndex) {
                dayCell.isToday()
                
            } else if indexPath.isLessThan(todayIndexPath, extraItem: firstWeekDayIndex) {
                dayCell.isLessThanCurrentDay()
                
            } else {
                dayCell.isDefault()
            }
            
            //            if let eventsForDay = self.eventsByIndexPath[indexPath] {
            //                dayCell.eventsCount = eventsForDay.count
            //            } else {
            //                dayCell.eventsCount = 0
            //            }
            
        } else {
            dayCell.clear()
        }
        
        return dayCell
    }
}
