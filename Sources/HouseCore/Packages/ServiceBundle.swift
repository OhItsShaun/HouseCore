//
//  ServiceBundle.swift
//  House
//
//  Created by Shaun Merchant on 12/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A service bundle is a collection of data addressed to a package & service, to be used by House Messages. 
///
/// A service bundle guarantees safety of message transmission by failing to instance unless the data to be sent 
/// passes validation assertions.
public struct ServiceBundle {
    
    /// The package the service is addressed to.
    public let package: PackageIdentifier
    
    /// The service identifier of the message.
    public let service: ServiceIdentifier
    
    /// The data of the message.
    public let data: Data
    
    /// Create a new service bundle.
    ///
    /// - Note: If the data exceeds the maximum service bundle size the initialiser will fail and return `nil`.
    ///
    /// - Parameters:
    ///   - package: The package to address.
    ///   - service: The service the data is for.
    ///   - data: The data for the service.
    public init?(package: PackageIdentifier, service: ServiceIdentifier, data: Data) {
        self.package = package
        self.service = service
        
        guard data.count <= Int(UInt16.max) else {
            return nil
        }
        
        self.data = data
    }
    
    /// Create a new service bundle.
    ///
    /// - Note: If the accumulated data from the archivables exceed the maximum service bundle size the initialiser will fail and return `nil`.
    ///
    /// - Parameters:
    ///   - package: The package to address.
    ///   - service: The service the data is for.
    ///   - archivables: A sequence of archivables to archive into the service bundle.
    public init?(package: PackageIdentifier, service: ServiceIdentifier, archivable: Archivable...) {
        self.package = package
        self.service = service
        
        var tempData = Data()
        for item in archivable {
            tempData.append(item.archive())
        }
        
        guard tempData.count <= Int(UInt16.max) else {
            return nil
        }
        
        self.data = tempData
    }

    
}

// MARK: - Archive
extension ServiceBundle: Archivable {
    
    public func archive() -> Data {
        /// Reserving correct amount prevents re-shuffling around memory.
        var data = Data(capacity: MemoryLayout<PackageIdentifier>.size + MemoryLayout<ServiceIdentifier>.size + self.data.count)
        
        data.append(self.package.archive())
        data.append(self.service.archive())
        data.append(self.data)
        
        return data
    }
    
}

// MARK: - Unarchive
extension ServiceBundle: Unarchivable {
    
    public static func unarchive(_ data: Data) -> ServiceBundle? {
        var data = data
        
        guard let packageData = data.remove(forType: PackageIdentifier.self) else {
            return nil
        }
        
        guard let package = PackageIdentifier.unarchive(packageData) else {
            return nil
        }
        
        guard let serviceData = data.remove(forType: ServiceIdentifier.self) else {
            return nil
        }
       
        guard let service = PackageIdentifier.unarchive(serviceData) else {
            return nil
        }
        
        return ServiceBundle(package: package, service: service, data: data)
    }
    
}

extension ServiceBundle: Equatable {
    
    public static func ==(lhs: ServiceBundle, rhs: ServiceBundle) -> Bool {
        return lhs.service == rhs.service && lhs.package == rhs.package && lhs.data == rhs.data
    }
    
}
