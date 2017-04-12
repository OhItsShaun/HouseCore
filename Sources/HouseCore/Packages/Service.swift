//
//  Service.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A service.
public struct Service {
    
    /// The identifier of the service.
    public let identifier: ServiceIdentifier
    
    /// The function that is applied to data the service has recieved.
    private let block: ((Data) -> Void)
    
    /// Create a new service.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of the service.
    ///   - block: The block that data is applied to when the service is performed.
    init(_ identifier: ServiceIdentifier, performs block: @escaping ((Data) -> Void)) {
        self.identifier = identifier
        self.block = block
    }
    
    /// Perform the service
    ///
    /// - Parameter data: The data to apply to the service.
    public func perform(on data: Data) {
        self.block(data)
    }
}

extension Service: Equatable {
    
    public static func ==(lhs: Service, rhs: Service) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}

extension Service: Hashable {
    
    public var hashValue: Int {
        get {
            return Int(self.identifier)
        }
    }
    
}
