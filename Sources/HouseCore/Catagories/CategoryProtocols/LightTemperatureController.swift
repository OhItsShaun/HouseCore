//
//  LightTemperatureController.swift
//  House
//
//  Created by Shaun Merchant on 17/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A House Extension that can control the temperature of a light.
public protocol LightTemperatureControllerDelegate: LightControllerDelegate {
    
    /// Set the temperature of the light to a given value.
    ///
    /// - Parameter lightTemperature: The temperature to set the light to.
    func setLightTemperature(to lightTemperature: LightTemperature)
    
    /// The temperature of the light was requested.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The temperature was requested by the House Hub and should be returned promptly using `didDetermineLightTemperature(was: LightTemperature, at: Date)`.
    ///
    /// ## House Hub
    /// The temperature was requested by the user and should message the appropriate House Extension for their light temperature.
    func didRequestLightTemperature()
    
    /// Appropriately handle a known temperature of the light at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The temperature and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The temperature and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - lightTemperature: The temperature of the light.
    ///   - time: The time at which the temperature was determined.
    func didDetermineLightTemperature(was lightTemperature: LightTemperature, at time: Date)
    
}

extension LightTemperatureControllerDelegate {
    
    public func didDetermineLightTemperature(was lightTemperature: LightTemperature) {
        self.didDetermineLightTemperature(was: lightTemperature, at: Date())
    }
    
}

/// Light temperature is represented as a unit of Mired (micro reciprocal degree), 
/// a conversion of Kelvin. Further information can be found at Mired's [Wikipedia](https://en.wikipedia.org/wiki/Mired).
///
/// Dividing 1,000,000 by the Kelvin value produces the Mired value:
/// ```
/// let mired = 1000000/temperature
/// ```
public typealias LightTemperature = UInt16
