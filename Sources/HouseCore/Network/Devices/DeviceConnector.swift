//
//  ConnectHouseDevice.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// A structure to hold a socket connection to a house device.
/// 
/// Mostly used by houseHub.
public struct HouseDeviceConnector {
    
    /// The house identifier of the device.
    public var houseIdentifier: HouseIdentifier
    
    /// The IP address of the device on the network.
    public var ipAddress: String

    /// Instance a new connector to a House Device.
    ///
    /// - Parameters:
    ///   - houseIdentifier: The House Identifier of the House Device.
    ///   - ipAddress: The IP address of the House Device.
    init(for houseIdentifier: HouseIdentifier, atAddress ipAddress: String) {
        Log.debug("Device Connector Update: \(houseIdentifier) at \(ipAddress)", in: .connectedDevices)
        self.houseIdentifier = houseIdentifier
        self.ipAddress = ipAddress
    }
    
}

extension HouseDeviceConnector {
    
    /// Create a new connection to the House Device.
    ///
    /// - Returns: A connection ready to recieve Messages to the House Device, nil if a connection could not be established.
    func newConnection() -> Socket? {
        Log.debug("Creating new connection for \(self.houseIdentifier) at \(self.ipAddress)", in: .connectedDevices)
        do {
            let socket = try Socket.create()
            
            if HouseDevice.current().role == .houseHub {
                try socket.connect(to: self.ipAddress, port: HNCP.extensionListeningPort)
            }
            else {
                try socket.connect(to: self.ipAddress, port: HNCP.hubListeningPort)
            }
            
            return socket
        }
        catch {
            Log.warning("Unable to create socket to House Device: \(error)", in: .networkMessagesWorker)
            return nil
        }
    }
    
}


// MARK: - Equatable
extension HouseDeviceConnector: Equatable {
    
    public static func == (lhs: HouseDeviceConnector, rhs: HouseDeviceConnector) -> Bool {
        return lhs.houseIdentifier == rhs.houseIdentifier
    }
    
}

// MARK: - Hashable
extension HouseDeviceConnector: Hashable {
    
    public var hashValue: Int {
        get {
            return self.houseIdentifier.hashValue
        }
    }
    
}
