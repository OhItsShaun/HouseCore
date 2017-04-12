//
//  CharacteristicStore.swift
//  House
//
//  Created by Shaun Merchant on 08/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import DataStructures

/// A storage for characteristics.
///
/// - Important: Storing values does not trigger House Events. It is for callers to trigger
///              the appropriate events upon storage.
public struct CharacteristicStore {
    
    /// The store for characteristics and values.
    private var stores = [Characteristic: PriorityQueue<RecordedValue>]()
    
    /// Create a new characteristic store.
    public init() {
        
    }
    
    /// Store a recorded value for a characteristic.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - characteristic: The characteristic the recorded value is associated with.
    public mutating func insertValue(_ value: RecordedValue, for characteristic: Characteristic) {
        if self.stores[characteristic] == nil {
            let priorityQueue = PriorityQueue<RecordedValue>(ascending: false)
            self.stores[characteristic] = priorityQueue
        }
        self.stores[characteristic]?.insert(value)
    }
    
    /// Retrieve the most recent value for a characteristic.
    ///
    /// - Note: "Most recent" is defined as the timestamp at which the value was recorded, not the 
    ///         most recently inserted value.
    ///
    /// - Parameter characteristic: The characteristic to retrieve the most recent value of.
    /// - Returns: The most recent value of the characteristic, `nil` if none exists
    public func latestValue(for characteristic: Characteristic) -> RecordedValue? {
        guard self.stores[characteristic] != nil else {
            return nil
        }
        return self.stores[characteristic]?.peek()
    }
    
    /// Retrieve all known values for a given characteristic.
    ///
    /// - Note: The list of values are **not** given in order of timestamp.
    ///
    /// - Important: The history of characteristics should not be assumed as complete or exhaustive. 
    ///              History could be pruned if neccessary due to consideration of memory.
    ///
    /// - Parameter characteristic: The characteristic to retrieve all values of.
    /// - Returns: The list of known values for a given characteristic.
    public func allValues(for characteristic: Characteristic) -> [RecordedValue] {
        guard self.stores[characteristic] != nil else {
            return []
        }
        
        return self.stores[characteristic]!.array
    }
    
    /// Delete all known values for a given charactierstic.
    ///
    /// - Parameter characteristic: The characteristic to delete all known values of.
    public mutating func deleteAllValues(for characteristic: Characteristic) {
        guard self.stores[characteristic] != nil else {
            return
        }
        
        self.stores[characteristic] = PriorityQueue<RecordedValue>()
    }
    
    /// Delete all known values.
    public mutating func deleteAllValues() {
        self.stores = [Characteristic: PriorityQueue<RecordedValue>]()
    }
}
