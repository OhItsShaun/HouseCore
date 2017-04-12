//
//  Characteristic.swift
//  House
//
//  Created by Shaun Merchant on 17/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// The different types of characteristics a House Device can produce.
public enum Characteristic: Hashable {
    
    /// The status of a light.
    case lightStatus
    
    /// The brightness of a light.
    case lightBrightness
    
    /// The temeprature of a light.
    case lightTemperature
    
    /// The state of a switch.
    case switchState
    
    /// The status of a motion sensor.
    case motionSensorStatus
    
    /// The reading of an ambient light sensor.
    case ambientLightSensorReading
}
