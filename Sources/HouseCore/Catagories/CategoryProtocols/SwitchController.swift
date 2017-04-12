//
//  SwitchController.swift
//  House
//
//  Created by Shaun Merchant on 14/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A switch controller represents a device that has binary state of on or off.
public protocol SwitchControllerDelegate {
    
    /// The state of the switch requested.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The switch state was requested by the House Hub and should be returned promptly using `didDetermineSwitchState(was: SwitchState, at: Date)`.
    ///
    /// ## House Hub
    /// The switch state reading was requested by the user and should message the appropriate House Extension for the state.
    func didRequestSwitchState()
    
    /// Appropriately handle a known switch state at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The switch state and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The switch state and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - ambientLight: The ambient light reading.
    ///   - time: The time at which the ambient light was determined.
    func didDetermineSwitchState(was state: SwitchState, at time: Date)
    
}


public extension SwitchControllerDelegate {
    
    public func didDetermineSwitchState(was state: SwitchState) {
        self.didDetermineSwitchState(was: state, at: Date())
    }
    
}

/// The status of a switch.
public enum SwitchState: UInt8 {
    
    /// The switch is on.
    case on
    
    /// The switch is off.
    case off
    
    /// The state of the switch is unable to be determined.
    case unavailable
    
}

extension SwitchState: Archivable {
    
    public func archive() -> Data {
        return self.rawValue.archive()
    }
    
}

extension SwitchState: Unarchivable {
    
    public static func unarchive(_ data: Data) -> SwitchState? {
        guard let rawValue = UInt8.unarchive(data) else {
            return nil
        }
        return SwitchState(rawValue: rawValue)
    }
}
