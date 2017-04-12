//
//  Updateable
//  House
//
//  Created by Shaun Merchant on 27/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/// Conformants to `UpdateableProcess` hand responsibility of the run loop and persisting themselves in memory to `BootstrapUpdatable`.
public protocol UpdateableProcess: HouseProcess {
    
    /// How often the extension will be notified to update with `update`.
	/// The update frequency is not guaranteed, treat as an approximation.
    var updateFrequency: TimeInterval { get }
    
    /// Notification that `update(time:)` will begin.
    ///
    /// - Important: House **will** wait for return to occur before updates begin.
    func updatesWillStart() -> Void
    
    /// Provides CPU time for the HouseDevice to perform operations.
    ///
    /// - Important: `updates` will execute sequentially, and House **will** wait for return before the next `update()` is issued.
    ///
    /// - Parameter time: The time at which the update was called.
    func update(at time: Date) -> Void
    
}

public extension UpdateableProcess {
    
    func updatesWillStart() {
        
    }
    
    func update(at time: Date) -> Void {
        
    }
    
}

/// An enumation of frequencies.
public enum UpdateFrequency: TimeInterval {
    
    /// As often as possible.
    case oftenAsPossible = 0.5
    
    /// A frequency of once every second.
    case everySecond = 1
    
    /// A frequency of once every 10 seconds.
    case every10Seconds = 10
    
    /// A frequency of once every 30 seconds.
    case every30Seconds = 30
    
    /// A frequency of once every minute.
    case everyMinute = 60
    
    /// A frequency of once every 5 minutes.
    case every5Minutes = 300
    
    /// A frequency of once every 15 minutes.
    case every15Minutes = 900
    
    /// A frequency of once every 30 minutes.
    case every30Minutes = 1800
    
    /// A frequency of once every hour.
    case everyHour = 3600
}
