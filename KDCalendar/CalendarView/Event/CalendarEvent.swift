//
//  CalendarEvent.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 07/02/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

public struct CalendarEvent {
    
    let startDate: Date
    let endDate: Date
    let color: UIColor
    let title: String?
    
    public init(startDate: Date, endDate: Date, color: UIColor = CalendarView.Style.cellEventColor, title: String? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
        self.title = title
    }
}
