/*
 * CalendarDayCell.swift
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

open class CalendarDayViewCell: UICollectionViewCell {
    
    private var containerViewConstraints: [NSLayoutConstraint] = []
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dayLabelConstraints: [NSLayoutConstraint] = []
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var eventsStackConstraints: [NSLayoutConstraint] = []
    private lazy var eventsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var maxNumbOfEvents = 0
    
    override open var description: String {
        let dayString = self.dayLabel.text ?? " "
        return "<DayCell (text:\"\(dayString)\")>"
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        configureViews()

        switch CalendarView.Style.cellShape {
        case .square:
            self.containerView.layer.cornerRadius = 0.0
        case .round:
            self.containerView.layer.cornerRadius = containerView.bounds.width * 0.5
        case .bevel(let radius):
            self.containerView.layer.cornerRadius = radius
        }
        
        maxNumbOfEvents = Int(self.containerView.bounds.size.width) / 4
    }
    
    private func configureViews() {
        NSLayoutConstraint.deactivate(containerViewConstraints)
        containerView.removeFromSuperview()
        NSLayoutConstraint.deactivate(dayLabelConstraints)
        dayLabel.removeFromSuperview()
        NSLayoutConstraint.deactivate(eventsStackConstraints)
        eventsStackView.removeFromSuperview()
        
        contentView.addSubview(containerView)
        containerViewConstraints = [
            containerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -2),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -2),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(containerViewConstraints)
        
        containerView.addSubview(dayLabel)
        dayLabelConstraints = [
            dayLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(dayLabelConstraints)
        
        containerView.addSubview(eventsStackView)
        eventsStackConstraints = [
            eventsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            eventsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            eventsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4)
        ]
        NSLayoutConstraint.activate(eventsStackConstraints)
    }
}

extension CalendarDayViewCell {
    
    func populateWith(day: Int) {
        dayLabel.text = "\(day)"
    }
    
    func clear() {
        dayLabel.text = nil
        eventsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func isSelectedCell() {
        dayLabel.textColor = CalendarView.Style.cellSelectedTextColor
        containerView.backgroundColor = CalendarView.Style.cellSelectedColor
        containerView.layer.borderWidth = CalendarView.Style.cellSelectedBorderWidth
        containerView.layer.borderColor = CalendarView.Style.cellSelectedBorderColor.cgColor
    }
    
    func isToday() {
        dayLabel.textColor = CalendarView.Style.cellTextColorToday
        containerView.backgroundColor = CalendarView.Style.cellColorToday
    }
    
    func isLessThanCurrentDay() {
        containerView.layer.borderWidth = 0
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
        dayLabel.textColor = CalendarView.Style.cellBeforeTodayTextColor
    }
    
    func isDefault() {
        containerView.layer.borderWidth = 0
        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
        dayLabel.textColor = CalendarView.Style.cellTextColorDefault
    }
    
    func setMarkEvents(events: [CalendarEvent]?) {
        eventsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let events = events else { return }
        
        for index in 0...maxNumbOfEvents {
            if index < events.count {
                let currentEvent = events[index]
                
                let eventView = UIView()
                eventView.backgroundColor = currentEvent.color
//                eventView.widthAnchor.constraint(equalToConstant: 2).isActive = true
                eventView.heightAnchor.constraint(equalToConstant: 2).isActive = true
                
                eventsStackView.addArrangedSubview(eventView)
            }
        }
    }
}
