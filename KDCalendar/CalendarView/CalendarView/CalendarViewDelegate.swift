//
//  CalendarViewDelegate.swift
//  CalendarView
//
//  Created by Vitor Mesquita on 07/02/2018.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import  UIKit

/**
 Delegate methods
 */
public protocol CalendarViewDelegate {
    
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date)
    func calendar(_ calendar : CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent])
    
    /* optional */
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) 
}

public extension CalendarViewDelegate {
    
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool {
        return true
    }
    
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void {
        
    }
}
