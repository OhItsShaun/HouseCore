//
//  HandshakeResponse.swift
//  House
//
//  Created by Shaun Merchant on 27/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// A report of the outcome of a handshake with a House Device.
public struct HandshakeResponse {
    
    /// The outcome of the attempted handshake.
    public enum Status {
        
        /// The handshake completed successfully and the connection is able to be used to transmit House messages.
        case success
        
        /// The handshake failed.
        case failed
    }
    
    /// The outcome of the handshake attempt.
    public let status: HandshakeResponse.Status
    
    /// The house identifier of the device that has been connected with, `nil` if the handshake failed.
    public let houseIdentifier: HouseIdentifier?
    
    /// The role of the device, `nil` if the handshake failed.
    public let role: HouseDevice.Role?
    
    public let socket: Socket?
    
    /// The categories device supports, `nil` if the handshake failed.
    public let supportedCategories: Set<HouseCategory>?
    
    /// Create a new report of the outcome of a handshake.
    ///
    /// - Parameters:
    ///   - status: The outcome of the handshake.
    ///   - identifier: The house identifier of the device that has been connected with, `nil` if the handshake failed.
    ///   - role: The role of the device, `nil` if the handshake failed.
    ///   - supportedCategories: The categories device supports, `nil` if the handshake failed.
    public init(_ status: HandshakeResponse.Status = .success, socket: Socket? = nil, identifier: HouseIdentifier? = nil, role: HouseDevice.Role? = nil, supportedCategories: Set<HouseCategory>? = nil) {
        self.status = status
        self.houseIdentifier = identifier
        self.role = role
        self.socket = socket
        self.supportedCategories = supportedCategories
    }
    
}
