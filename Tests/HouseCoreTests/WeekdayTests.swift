//
//  WeekdayTests.swift
//  House
//
//  Created by Shaun Merchant on 16/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class WeekdayTests: XCTestCase {

    func testRawValuePerformance() {
        let weekdays = Weekday.all()
        
        self.measure {
            for _ in 0..<1000 {
                for day in weekdays {
                    _ = self.incrementForNext(of: day)
                }
            }
        }
    }

    func testSwitchPerformance() {
        let weekdays = Weekday.all()
        
        self.measure {
            for _ in 0..<1000 {
                for day in weekdays {
                    _ = self.switchForNext(of: day)
                }
            }
        }
    }
    
    func incrementForNext(of day: Weekday) -> Weekday {
        let next = day.rawValue + 1
        
        if let nextDay =  Weekday(rawValue: next) {
            return nextDay
        }
        
        return .monday
    }
    
    func switchForNext(of day: Weekday) -> Weekday {
        switch day {
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
    
    
}
