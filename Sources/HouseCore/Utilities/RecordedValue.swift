//
//  RecordedValue.swift
//  House
//
//  Created by Shaun Merchant on 24/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A value that has been recorded at a point in time.
public struct RecordedValue {
    
    /// The value that has been recorded.
    public var value: Archivable
    
    /// The time at which the value was recorded.
    public var recorded: Date
    
    /// Create a new recorded value.
    ///
    /// - Parameters:
    ///   - value: The value recorded.
    ///   - time: The time the value was recorded.
    public init(_ value: Archivable, recordedAt time: Date = Date()) {
        self.value = value
        self.recorded = time
    }
    
}

extension RecordedValue: Equatable {
    
    public static func == (lhs: RecordedValue, rhs: RecordedValue) -> Bool {
        return lhs.recorded == rhs.recorded && lhs.value.archive() == rhs.value.archive()
    }
    
}

extension RecordedValue: Comparable {
    
    public static func <(lhs: RecordedValue, rhs: RecordedValue) -> Bool {
        return lhs.recorded < rhs.recorded
    }
    
    public static func <=(lhs: RecordedValue, rhs: RecordedValue) -> Bool {
        return lhs.recorded <= rhs.recorded
    }
    
    public static func >=(lhs: RecordedValue, rhs: RecordedValue) -> Bool {
        return lhs.recorded >= rhs.recorded
    }
    
    public static func >(lhs: RecordedValue, rhs: RecordedValue) -> Bool {
        return lhs.recorded >= rhs.recorded
    }
    
}
