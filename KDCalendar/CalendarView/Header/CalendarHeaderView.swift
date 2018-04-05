/*
 * CalendarHeaderView.swift
 * Created by Michael Michailidis on 07/04/2015.
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

class CalendarHeaderView: UIView {
    
    private var monthLabelConstraints: [NSLayoutConstraint] = []
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CalendarView.Style.headerFontName, size: 20.0)
        return label
    }()
    
    private var weekDaysStackConstraints: [NSLayoutConstraint] = []
    private lazy var weekDaysStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 0
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        monthLabel.textColor = CalendarView.Style.headerTextColor
        weekDaysStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let formatter = DateFormatter()
        formatter.shortWeekdaySymbols.forEach { (weekDay) in
            weekDaysStack.addArrangedSubview(buildWeekDayLabelWith(title: weekDay))
        }
    }
    
    private func configureViews() {
        NSLayoutConstraint.deactivate(monthLabelConstraints)
        monthLabel.removeFromSuperview()
        NSLayoutConstraint.deactivate(weekDaysStackConstraints)
        weekDaysStack.removeFromSuperview()
        
        addSubview(monthLabel)
        monthLabelConstraints = [
            monthLabel.topAnchor.constraint(equalTo: topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(monthLabelConstraints)
        
        addSubview(weekDaysStack)
        weekDaysStackConstraints = [
            weekDaysStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            weekDaysStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekDaysStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekDaysStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(weekDaysStackConstraints)
    }
    
    private func buildWeekDayLabelWith(title: String) -> UILabel {
        let weekdayLabel = UILabel()
        weekdayLabel.font = UIFont(name: CalendarView.Style.headerFontName, size: 14.0)
        weekdayLabel.text = title
        weekdayLabel.textColor = CalendarView.Style.headerTextColor
        weekdayLabel.textAlignment = .center
        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        return weekdayLabel
    }
}

extension CalendarHeaderView {
    
    func setHeaderTitle(_ text: String) {
        monthLabel.text = text
    }
}
