//
//  BootstrapStartable.swift
//  House
//
//  Created by Shaun Merchant on 27/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// `BootstrapStartable` acts as a harness for an `StartableProcess` keeping the
/// process in memory and starting the process until it is told to stop or the
/// process finishes execution.
internal final class BootstrapStartable {
    
    /// The House Extension.
    private let startable: StartableProcess
    
    /// Create a new bootable House Extension that conforms to the 'Startable protocol.
    ///
    /// - parameter startable: The Startable to boot with.
    ///
    /// - returns: A bootable object that can begin the Startable life cycle.
    init(with startable: StartableProcess) {
        Log.debug("Initialising StartableProcess", in: .boot)
        self.startable = startable
    }
    
    /// Signal the House Extension to begin execution.
    public func start() {
        Log.debug("Starting StartableProcess", in: .boot)
        DispatchQueue.global(qos: .userInteractive).async {
            self.startable.start()
        }
    }
}
