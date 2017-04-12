//
//  HouseIdentifier.swift
//  House
//
//  Created by Shaun Merchant on 27/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
import Random 

/// A unique identifier to represent a House Device.
///
/// - Note: Every House Extension must have a unique identifier that is not a reserved identifier of `1` or `0`.
///         Undefiend behaviour will occur if two Extensions share one identifier.
public typealias HouseIdentifier = UInt64

extension HouseIdentifier {
    
    /// The identifier of the House Hub.
    public static var hub: HouseIdentifier = 1
    
    /// A reserved identifier used to indicate error.
    public static var null: HouseIdentifier = 0
    
}

extension HouseIdentifier {
    
    /// Generate a random identifier that can be assumed to be unique (probably).
    ///
    /// - Returns: A random identifier.
    public static func random() -> UInt64 {
        return UInt64(Random.generate())
    }
    
}
