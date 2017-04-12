//
//  LightBrightnessController.swift
//  House
//
//  Created by Shaun Merchant on 17/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A House Extension that can control the brightness of a light.
public protocol LightBrightnessControllerDelegate: LightControllerDelegate {
    
    /// Set the brightness of the light to a given value.
    ///
    /// - Parameter lightBrightness: The brightness to set the light to.
    func setLightBrightness(to lightBrightness: LightBrightness)
    
    /// The brightness of the light was requested.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The brightness was requested by the House Hub and should be returned promptly using `didDetermineLightBrightness(was: LightBrightness, at: Date)`.
    ///
    /// ## House Hub
    /// The brightness was requested by the user and should message the appropriate House Extension for their light brightness.
    func didRequestLightBrightness()
    
    /// Appropriately handle a known brightness of the light at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The brightness and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The brightness and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - lightBrightness: The brightness of the light.
    ///   - time: The time at which the brightness was determined.
    func didDetermineLightBrightness(was lightBrightness: LightBrightness, at time: Date)
    
}

public extension LightBrightnessControllerDelegate {
    
    public func didDetermineLightBrightness(was lightBrightness: LightBrightness) {
        self.didDetermineLightBrightness(was: lightBrightness, at: Date())
    }
    
}

/// A type to represent the brightness of a light.
/// Values will range from `0.0` to `1.0`, whereby `0.0` represent the lowest brightness possible or off
/// and `1.0` represents the brightest the light can be.
public typealias LightBrightness = Float
