//
//  ServiceController.swift
//  House
//
//  Created by Shaun Merchant on 23/08/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/// A registry for services and packages.
public class PackageRegistry {
    
    fileprivate var packages = [PackageIdentifier: [ServiceIdentifier: Service]]()
   
}

// MARK: - Registration
public extension PackageRegistry {
    
    /// Register a service and associated block into a package.
    ///
    /// - Parameters:
    ///   - package: The package to register the service for.
    ///   - serviceIdentifier: The service to associate the block to.
    ///   - block: The closure to perform when the service and package are called.
    public func register(in package: PackageIdentifier, service serviceIdentifier: ServiceIdentifier, perform block: @escaping (Data) -> Void) {
        Log.debug("Registering: \(package)-\(serviceIdentifier)", in: .packageRegistry)
        let service = Service(serviceIdentifier, performs: block)
        self.register(in: package, service: service)
    }
    
    /// Register an instance of `Service` into a package.
    ///
    /// - Parameters:
    ///   - package: The package to register the `Service` into.
    ///   - service: The `Service` to register into the package.
    public func register(in package: PackageIdentifier, service: Service) {
        if var services = self.packages[package] {
            services[service.identifier] = service
            self.packages[package] = services
        }
        else {
            self.packages[package] = [service.identifier: service]
        }
    }
    
    /// Remove an entire package.
    ///
    /// - Parameter package: The package to remove.
    public func deregister(package: PackageIdentifier) {
        self.packages.removeValue(forKey: package)
    }
    
    /// Remove a service from a package.
    ///
    /// - Parameters:
    ///   - package: The package to remove the service from.
    ///   - service: The service to remove.
    public func deregister(in package: PackageIdentifier, service: ServiceIdentifier) {
        if var services = self.packages[package] {
            services.removeValue(forKey: service)
            self.packages[package] = services
        }
    }
    
}

// MARK: - Service Calling
extension PackageRegistry {
    
    /// Apply a given service bundle to the package registry.
    ///
    /// - Parameter serviceBundle: The service bundle to apply to the package registry.
    public func handle(bundle serviceBundle: ServiceBundle) {
        Log.debug("Handling Bundle: \(serviceBundle.package) package for \(serviceBundle.service) service...")
        if let services = self.packages[serviceBundle.package] {
            if let service = services[serviceBundle.service] {
                service.perform(on: serviceBundle.data)
            }
            else {
                Log.warning("Service (\(serviceBundle) not found.", in: .packageRegistry)
            }
        }
        else {
            Log.warning("Package (\(serviceBundle) not found.", in: .packageRegistry)
        }
    }
    
}
