//
//  AmbientLightSensor.swift
//  House
//
//  Created by Shaun Merchant on 07/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A House Extension sensor that can determine the level of ambient light in its environment.
public protocol AmbientLightSensorDelegate {
    
    /// A sensor reading of the amount of ambient light in the House Extension's enrivonment was requested.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The ambient light reading was requested by the House Hub and should be returned promptly using `didDetermineAmbientLightReading(was: AmbientLight, at: Date)`.
    ///
    /// ## House Hub
    /// The ambient light reading was requested by the user and should message the appropriate House Extension for a reading.
    func didRequestAmbientLightReading()
    
    /// Appropriately handle a known ambient light reading at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The ambient light reading and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The ambient light reading and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - ambientLight: The ambient light reading.
    ///   - time: The time at which the ambient light was determined.
    func didDetermineAmbientLightReading(was ambientLight: AmbientLight, at time: Date)
    
}

public extension AmbientLightSensorDelegate {
    
    public func didDetermineAmbientLightReading(was ambientLight: AmbientLight) {
        self.didDetermineAmbientLightReading(was: ambientLight, at: Date())
    }
    
}

/// A type to represent the level of a ambient light.
/// Values will range range from `0.0` to `1.0`, whereby `0.0` represent total darkness
/// and `1.0` represents the brightest value the sensor could determine.
public typealias AmbientLight = Float
