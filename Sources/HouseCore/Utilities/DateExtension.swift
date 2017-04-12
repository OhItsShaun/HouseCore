//
//  DateExtension.swift
//  House
//
//  Created by Shaun Merchant on 02/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

extension Date {
    
    /// The amount of time that has passed between the start of the current day and the time at which the getter was called.
    public static var timeIntervalIntoCurrentDay: TimeInterval {
        get {
            let currentDay = Calendar.current.startOfDay(for: Date())
            
            return Date().timeIntervalSince(currentDay)
        }
    }
    
    /// The amount of time that has paseed between the start of the current day and a given point in time.
    ///
    /// - Parameter date: The point in time to determine the time difference of from the start of the current day.
    /// - Returns: The amount of time that has paseed between the start of the current day and the given point in time.
    public static func timeIntervalIntoCurrentDay(from date: Date) -> TimeInterval {
        let currentDay = Calendar.current.startOfDay(for: Date())
        
        return currentDay.timeIntervalSince(date)
    }
    
    /// Returns the current time rounded to the nearest minute.
    ///
    /// - Returns: The current time rounded ot the nearest minute.
    public static func roundedToMinute() -> Date {
        let currentTime = Date()
        
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        
        guard let rounded = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: currentTime) else {
            fatalError("Failed Time Look Up. Serious Bug.")
        }
        
        return rounded
    }
    
    public static var startOfDay: Date {
        get {
            return Calendar.current.startOfDay(for: Date())
        }
    }
}

extension TimeInterval {
    
    /// The amount of seconds in a day.
    public static var secondsInADay: TimeInterval {
        get {
            return TimeInterval(86400)
        }
    }
    
}
