//
//  CategoryDelegate.swift
//  House
//
//  Created by Shaun Merchant on 17/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A collection of references for all possible House Category delegates. All references are initially `nil`.
///
/// ## Discussion
/// houseCore has a structure of `HouseCategoryDelegates` in instances of `HouseDevice`.
/// House processes support categories by altering the reference from `nil` to the respective
/// delegate prior to opening the houseNetwork.
/// 
/// - Important: References to delegates in memory are **strong**.
public struct HouseCategoryDelegates {
    
    /// The delegate for supporting light controller events.
    public var lightControllerDelegate: LightControllerDelegate? = nil
    
    /// The delegate for supporting light brightness controller events.
    public var lightBrightnessControllerDelegate: LightBrightnessControllerDelegate? = nil
    
    /// The delegate for supporting light temperature controller events.
    public var lightTemperatureControllerDelegate: LightTemperatureControllerDelegate? = nil
    
    /// The delegate for supporting switch controller events.
    public var switchControllerDelegate: SwitchControllerDelegate? = nil
    
    /// The delegate for supporting motion sensor events.
    public var motionSensorDelegate: MotionSensorDelegate? = nil
    
    /// The delegate for supporting ambient light sensor events.
    public var ambientLightSensorDelegate: AmbientLightSensorDelegate? = nil
    
    /// The delegate for supporting ambient light sensor events.
    public var hubInterfaceDelegate: HubInterfaceDelegate? = nil
    
    
}

public extension HouseCategoryDelegates {
    
    /// Create a set of currently supported categories.
    ///
    /// - Note: The set of supported categories is determined by checking whether the delegates in `HouseCategoryDelegates` are `nil`.
    ///
    /// - Returns: The set of currently supported categories.
    public func supportedCategories() -> Set<HouseCategory> {
        var categories = Set<HouseCategory>()
    
        if let _ = self.lightControllerDelegate {
            categories.insert(.lightController)
        }
        if let _ = self.lightBrightnessControllerDelegate {
            categories.insert(.lightBrightnessController)
        }
        if let _ = self.lightTemperatureControllerDelegate {
            categories.insert(.lightTemperatureController)
        }
        if let _ = self.ambientLightSensorDelegate {
            categories.insert(.ambientLightSensor)
        }
        if let _ = self.motionSensorDelegate {
            categories.insert(.motionSensor)
        }
        if let _ = self.switchControllerDelegate {
            categories.insert(.switchController)
        }
        if let _ = self.hubInterfaceDelegate {
            categories.insert(.hubInterface)
        }
        
        return categories 
    }
    
}
