//
//  main.swift
//  Extension
//
//  Created by Shaun Merchant on 26/07/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

public struct HouseRuntime {
    
    private static var runner: Any? = nil
    
    public static func run(_ process: HouseProcess, as role: HouseDevice.Role = .houseExtension) {
        guard #available(OSX 10.12, *) else {
            fatalError("Unsupported platform. Compile for OSX 10.12.")
        }
        
        Cache.load()    // Load previous state if exists.
    
        HouseDevice.create(with: process, as: role)   // Create the device.
        
        if let houseExtension = process as? UpdateableProcess {
            let bootstrap = BootstrapUpdateable(with: houseExtension)
            bootstrap.start()
            self.runner = bootstrap
        }
        else if let houseExtension = process as? StartableProcess {
            let bootstrap = BootstrapStartable(with: houseExtension)
            bootstrap.start()
            self.runner = bootstrap
        }
        else {
            fatalError("Cannot run HouseExtensionDelegate.\nHouseExtensionDelegate conforms to HouseExtensionProcess but not a known derivative.")
        }
        
        RunLoop.main.run()
    }
    
    public static func stop() {
        if let runner = self.runner as? BootstrapUpdateable {
            runner.stop()
        }
    }
    
}
