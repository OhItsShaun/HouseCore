//
//  BootstrapUpdateable.swift
//  House
//
//  Created by Shaun Merchant on 26/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// `BootstrapUpdateable` acts as a harness for an `UpdateableProcess` keeping the
/// process in memory and "heartbeating" at its requested interval until the instance
/// of `BootstrapUpdateable` is told to `stop()`.
internal final class BootstrapUpdateable {
    
    /// The House Extension to run.
    private let runnable: UpdateableProcess
    
    /// The timer that updates our process.
    private var timer: Timer? = nil
    
    /// The serial queue to handle calling `update()` on `runnable`.
    private var updateQueue = DispatchQueue(label: "houseBoot", qos: .userInteractive)

    /// Create a new bootable House Extension that conforms to the 'Updateable protocol.
    ///
    /// - Parameter runnable: The Updateable to boot with.
    ///
    /// - Returns: A bootable object that can begin the Updateable life cycle.
    init(with runnable: UpdateableProcess) {
        Log.debug("Initialising UpdateableProcess", in: .boot)
        self.runnable = runnable
    }
    
    /// Start updating the runnable process.
    @available(OSX 10.12, *)
    public func start() {
        Log.debug("Starting UpdateableProcess with \(self.runnable.updateFrequency) update requency", in: .boot)
    
        Log.debug("Sending `updatesWillStart` notification", in: .boot)
        self.runnable.updatesWillStart()
        
        Log.debug("Beginning `updates(time:) timer", in: .boot)
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: self.runnable.updateFrequency, repeats: true) { timer in
            self.update()
        }
        self.timer?.fire()
        RunLoop.main.add(self.timer!, forMode: .defaultRunLoopMode)
    }
    
    /// The update selector for the timer to call.
    private func update() {
        autoreleasepool {
            self.updateQueue.async {
                autoreleasepool {
                    self.runnable.update(at: Date())
                }
            }
        }
    }
    
    public func stop() {
        self.timer?.invalidate()
    }
}
