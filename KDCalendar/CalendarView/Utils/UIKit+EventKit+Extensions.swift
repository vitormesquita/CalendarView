/*
 * KDCalendarView.swift
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
import EventKit

extension EKEvent {
    var isOneDay : Bool {
        let components = Calendar.current.dateComponents([.era, .year, .month, .day], from: self.startDate, to: self.endDate)
        return (components.era == 0 && components.year == 0 && components.month == 0 && components.day == 0)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension IndexPath {
    
    func equals(_ indexPath: IndexPath?, extraItem: Int = 0) -> Bool {
        guard let indexPath = indexPath else { return false }
        let formattedItem = indexPath.item + extraItem
        return item == formattedItem && indexPath.section == section
    }
    
    func isLessThan(_ indexPath: IndexPath?, extraItem: Int = 0) -> Bool {
        guard let indexPath = indexPath else { return true }
        let formattedItem = indexPath.item + extraItem
        
        guard indexPath.section <= section else {
            return true
        }
        
        return item < formattedItem && indexPath.section >= section
    }
}
