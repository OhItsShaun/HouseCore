//
//  Weekday.swift
//  House
//
//  Created by Shaun Merchant on 07/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// An enumeration of the days in the week for Gregorian calendars.
public enum Weekday: UInt8 {
    /// Monday.
    case monday
    
    /// Tuesday.
    case tuesday
    
    /// Wednesday.
    case wednesday
    
    /// Thursday.
    case thursday
    
    /// Friday.
    case friday
    
    /// Saturday.
    case saturday
    
    /// Sunday.
    case sunday
}

public extension Weekday {
    
    /// Create an ordered list of all days in the week.
    ///
    /// - Note: House treats a week as beginning on monday and ends on sunday.
    ///
    /// - Returns: An ordered list of all the days in the week.
    static public func all() -> [Weekday] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

public extension Weekday {
    
    /// Find the day that comes logically after the current value.
    ///
    /// - Returns: The day that is logically next after the current value.
    public func nextDay() -> Weekday {
        // Tests indicate switch is faster than rawValue
        switch self {
        case .monday:
            return .tuesday
        case .tuesday:
            return .wednesday
        case .wednesday:
            return .thursday
        case .thursday:
            return .friday
        case .friday:
            return .saturday
        case .saturday:
            return .sunday
        case .sunday:
            return .sunday
        }
    }
    
    public static func from(string: String) -> Weekday? {
        switch string {
        case "Monday":
            return .monday
        case "Tuesday":
            return .tuesday
        case "Wednesday":
            return .wednesday
        case "Thursday":
            return .thursday
        case "Friday":
            return .friday
        case "Saturday":
            return .saturday
        case "Sunday":
            return .sunday
        default:
            return nil
        }
    }
    
}

public extension Weekday {
    
    public static var today: Weekday {
        get {
            let component = Calendar.current.component(.weekday, from: Date())
            let weekdayString = Calendar.current.weekdaySymbols[component-1]
            return Weekday.from(string: weekdayString)!
        }
    }
}
