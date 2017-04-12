//
//  Categories.swift
//  House
//
//  Created by Shaun Merchant on 08/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// The different types of House Categories a House Device can conform to.
public enum HouseCategory: UInt16, Hashable {
    
    /// A light controller.
    case lightController
    
    /// A light brightness controller.
    case lightBrightnessController
    
    /// A light temperature controller.
    case lightTemperatureController
    
    /// An ambient light sensor.
    case ambientLightSensor
    
    /// A motion sensor.
    case motionSensor
    
    /// A switch controller.
    case switchController
    
    /// A Hub interface.
    case hubInterface
    
    /// Return an ordered list of all possible House Categories.
    ///
    /// - Returns: An ordered list of all possible House Categories.
    public static func all() -> [HouseCategory] {
        return [.lightController, .lightBrightnessController, .lightTemperatureController, .ambientLightSensor, .motionSensor, .switchController, .hubInterface]
    }
}


public extension HouseCategory {

    /// Create an ordered list of bitmasks that represent a given set of supported categories.
    ///
    /// - Parameter supportedCategories: A set of categories to enable in the bitmask.
    /// - Returns: An ordered list of bitmasks that represent a set of enabled categories.
    public static func bitmasks(from supportedCategories: Set<HouseCategory>) -> [UInt8] {
        let allCategories = HouseCategory.all().sorted { (cat1, cat2) -> Bool in
            return (cat1.rawValue < cat2.rawValue)
        }
        var supported = [Bool](repeating: false, count: allCategories.count)
        
        for (index, category) in allCategories.enumerated() {
            if supportedCategories.contains(category) {
                supported[index] = true
            }
        }
        
        let bytesNeeded = allCategories.count / 8 + 1
        var bitmasks = [UInt8](repeating: 0b0, count: bytesNeeded)
        
        for (index, support) in supported.enumerated() {
            if support {
                let bitmask = bitmasks[index / 8]
                let bitFlip: UInt8 = UInt8(index % 8)
                let bit: UInt8 = 0b1
                let bitShifted = bit << bitFlip
                let newBitmask = bitmask ^ bitShifted
                bitmasks[index / 8] = newBitmask
            }
        }
        return bitmasks
    }

    /// Create a set of categories that a bitmask supports.
    ///
    /// - Parameter bitmasks: An ordered list of bitmasks to represent enabled categories.
    /// - Returns: A set of categories that the bitmasks support.
    public static func categories(from bitmasks: Array<UInt8>) -> Set<HouseCategory> {
        let allCategories = HouseCategory.all().sorted { (cat1, cat2) -> Bool in
            return (cat1.rawValue < cat2.rawValue)
        }
        var supportedCategories = Set<HouseCategory>()
        
        for (maskIndex, bitmask) in bitmasks.enumerated() {
            for bitIndex in 0..<8 {
                let bitShifted = bitmask >> UInt8(bitIndex)
                let lsb = bitShifted & 0b1
                if lsb == 1 {
                    let index = maskIndex * 8 + bitIndex
                    guard index < allCategories.count else {
                        continue
                    }
                    supportedCategories.insert(allCategories[index])
                }
            }
        }
        return supportedCategories
    }
}
