//
//  LightController.swift
//  House
//
//  Created by Shaun Merchant on 20/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A House Extension that can control whether a light is on or off.
public protocol LightControllerDelegate {
    
    /// Turn on the light.
    func turnOnLight()
    
    /// Turn off the light.
    func turnOffLight()
    
    /// The light status was requested. 
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    /// 
    /// ## House Extensions
    /// The status was requested by the House Hub and should be returned promptly using `didDetermineLightStatus(was: Status, at: Date)`.
    ///
    /// ## House Hub
    /// The status was requested by the user and should message the appropriate House Extension for their light status.
    func didRequestLightStatus()
    
    /// Appropriately handle a known status of the light at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The status and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The status and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - status: The status of the light.
    ///   - time: The time at which the status was determined.
    func didDetermineLightStatus(was status: LightStatus, at time: Date)
}

public extension LightControllerDelegate {
    
    public func didDetermineLightStatus(was status: LightStatus) {
        self.didDetermineLightStatus(was: status, at: Date())
    }
    
}

/// The status of a light.
public enum LightStatus: UInt8 {
    
    /// The light is on.
    case on
    
    /// The light is off.
    case off
    
    /// The light is unavailable.
    case unavailable
    
}

extension LightStatus: Archivable {
    
    public func archive() -> Data {
        return self.rawValue.archive()
    }
    
}

extension LightStatus: Unarchivable {
    
    public static func unarchive(_ data: Data) -> LightStatus? {
        guard let value = UInt8.unarchive(data) else {
            return nil
        }
        
        return LightStatus(rawValue: value)
    }
    
}
