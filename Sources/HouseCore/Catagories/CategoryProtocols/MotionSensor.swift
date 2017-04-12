//
//  MotionSensor.swift
//  House
//
//  Created by Shaun Merchant on 07/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A House Extension sensor that can determine if there has been motion in its environment.
public protocol MotionSensorDelegate {
    
    /// A sensor reading of motion in the House Extension's enrivonment was requested.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The motion reading was requested by the House Hub and should be returned promptly using `didDetermineMotionSensorStatus(was: MotionStatus, at: Date)`.
    ///
    /// ## House Hub
    /// The motion reading was requested by the user and should message the appropriate House Extension for a reading.
    func didRequestMotionSensorStatus()
    
    /// Appropriately handle a known motion reading at a given time.
    ///
    /// - Important: The behaviour exhibited upon calling depends upon whether the conformant is a House Extension or House Hub.
    ///
    /// ## House Extensions
    /// The motion reading and time should be messaged back to the House Hub. A default implementation is provided.
    ///
    /// ## House Hub
    /// The motion reading and time was messaged from the House Extension. It should be appropriately recorded and events triggered.
    ///
    /// - Parameters:
    ///   - motionStatus: The motion reading.
    ///   - time: The time at which the motion reading was determined.
    func didDetermineMotionSensorStatus(was motionStatus: MotionStatus, at time: Date)
    
}

extension MotionSensorDelegate {
    
    func didDetermineMotionSensorStatus(was motionStatus: MotionStatus) {
        self.didDetermineMotionSensorStatus(was: motionStatus, at: Date())
    }
    
}

/// The state of motion.
public enum MotionStatus: UInt8 {
    
    // Motion has been detected.
    case motionDetected
    
    // No motion is currently detected.
    case noMotionDetected
}

extension MotionStatus: Archivable {
    
    public func archive() -> Data {
        return self.rawValue.archive()
    }
    
}

extension MotionStatus: Unarchivable {
    
    public static func unarchive(_ data: Data) -> MotionStatus? {
        guard let rawValue = UInt8.unarchive(data) else {
            return nil
        }
        
        return MotionStatus(rawValue: rawValue)
    }
    
}
