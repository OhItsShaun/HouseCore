//
//  StartableProcess.swift
//  House
//
//  Created by Shaun Merchant on 27/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/// Conformants to `StartableProcess` take responsibility of the run loop and persisting themselves in memory.
///
/// `BootstrapStartable` will initialise conformants and hands over **all** responsibility to `StartableProcess` with `start()`
/// and will **not** make any subsequent calls for that execution run.
///
/// - Important: Only conform if you know what you're doing. If in doubt, use `UpdateableProcess`.
public protocol StartableProcess: HouseProcess {
    
    /// Start the House Device.
    func start()
    
}
