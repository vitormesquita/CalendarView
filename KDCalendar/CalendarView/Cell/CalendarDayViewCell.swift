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
    
    private let eventsContainerView = UIView()
    
    var eventsCount = 0 {
        didSet {
            //            self.dotsView.isHidden = (eventsCount == 0)
            self.setNeedsLayout()
        }
    }
    
    override open var description: String {
        let dayString = self.dayLabel.text ?? " "
        return "<DayCell (text:\"\(dayString)\")>"
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        configureViews()
        //        var elementsFrame = self.bounds.insetBy(dx: 3.0, dy: 3.0)
        //
        //        if CalendarView.Style.cellShape.isRound { // square of
        //            let smallestSide = min(elementsFrame.width, elementsFrame.height)
        //            elementsFrame = elementsFrame.insetBy(dx: (elementsFrame.width - smallestSide) / 2.0, dy: (elementsFrame.height - smallestSide) / 2.0)
        //        }
        //
        //        self.bgView.frame           = elementsFrame
        //        self.textLabel.frame        = elementsFrame
        //
        //        let size                            = self.bounds.height * 0.08 // always a percentage of the whole cell
        //        self.dotsView.frame                 = CGRect(x: 0, y: 0, width: size, height: size)
        //        self.dotsView.center                = CGPoint(x: self.textLabel.center.x, y: self.bounds.height - (2.5 * size))
        //        self.dotsView.layer.cornerRadius    = size * 0.5 // round it
        //
        switch CalendarView.Style.cellShape {
        case .square:
            self.containerView.layer.cornerRadius = 0.0
        case .round:
            self.containerView.layer.cornerRadius = containerView.bounds.size.width * 0.5
        case .bevel(let radius):
            self.containerView.layer.cornerRadius = radius
        }
    }
    
    private func configureViews() {
        NSLayoutConstraint.deactivate(containerViewConstraints)
        containerView.removeFromSuperview()
        NSLayoutConstraint.deactivate(dayLabelConstraints)
        dayLabel.removeFromSuperview()
        
        contentView.addSubview(containerView)
        containerViewConstraints = [
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
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
    }
}

extension CalendarDayViewCell {
    
    func populateWith(day: Int) {
        dayLabel.text = "\(day)"
    }
    
    func clear() {
        dayLabel.text = nil
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
}
