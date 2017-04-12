//
//  ReceiverParticipator.swift
//  House
//
//  Created by Shaun Merchant on 18/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket
#if os(Linux)
    import Dispatch
#endif

/// A delegate to allow House Extensions to participate in the House Network.
public final class HouseNetworkRecieverParticipator: HouseNetworkParticipatorDelegate, MessageOutboxResponderDelegate {
    
    /// Known devices and their connectors.
    private var houseDevices = HouseDeviceConnectors()
    
    /// A lock on messages.
    fileprivate var writeLock = DispatchQueue(label: "houseNetwork.writeLock", qos: .userInitiated)
    
    /// Create a new House Network delegate for House Extensions to participate in the House Network.
    /// The outbox of the current House Device will be set to route messages through the instanced 
    /// delegate.
    public init () {
        HouseDevice.current().messageOutbox.outboxResponderDelegate = self
    }
    
    public func handleNewConnection(using socket: Socket) {
        Log.debug("Recieved device connection (\(socket.remoteHostname)). Handling connection...", in: .network)
        
        let response = self.performHandshake(with: socket)

        HouseNetwork.current().responseDelegate?.handshakeDidOccur(with: response)
        
//        guard response.status == .success, let houseIdentifier = response.houseIdentifier else {
//            Log.debug("Device connection (\(socket.remoteHostname)) failed handshake", in: .network)
//            return
//        }
//        
//        Log.debug("Device connection (\(socket.remoteHostname)) succeeded handshake.", in: .network)
//        self.houseDevices.updateConnector(address: socket.remoteHostname, activeSocket: socket, for: houseIdentifier)
//        
//        
//        Log.debug("Stopping UDP Beacon...", in: .network)
//        HouseNetwork.current().beaconDelegate = nil
    }
    
    public func performHandshake(with socket: Socket) -> HandshakeResponse {
        do {
            ///
            /// 1. We expect to recieve HNCP.initiation from houseHub
            ///
            var data = Data(capacity: 1)
            var bytesRead: Int = 0
            
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                // Timed out. Therefore, cancel the handshake.                
                Log.fatal("Ext - Timeout waiting for init", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            guard let initResponse = UInt8.unarchive(data) else {
                throw HNCP.Error.FailedHNCP(message: "Could not unarchive initiation data")
            }
            guard initResponse == HNCP.initiation else {
                throw HNCP.Error.FailedHNCP(message: "Response did not match initiation")
            }
            Log.debug("Ext - Recieved Initiaton", in: .networkHandshake)
            
            ///
            /// 2. We send to houseHub our HNCP.acknolwedgement and our HNCP.version
            ///
            Log.debug("Ext - Sending Ack+Ver", in: .networkHandshake)
            try socket.write(from: HNCP.acknowledgement.archive() + HNCP.version.archive())
            
            ///
            /// 3. We expect to receive HNCP.versionAcceptance or HNCP.versionRejection
            ///
            data = Data(capacity: 1)
            
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                // Timed out. Therefore, cancel the handshake.
                Log.fatal("Ext - Timeout waiting for version accept or reject", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            guard let versionReponse = UInt8.unarchive(data) else {
                throw HNCP.Error.FailedHNCP(message: "Could not unarchive version data")
            }
            guard versionReponse == HNCP.versionAcceptance else {
                throw HNCP.Error.FailedHNCP(message: "Reponse did not match version acceptance")
            }
            Log.debug("Ext - Version accepted", in: .networkHandshake)
            
            ///
            /// 4. We send to houseHub our unique device identifier
            ///
            Log.debug("Ext - Sending identifier \(HouseDevice.current().identifier)", in: .networkHandshake)
            try socket.write(from: HouseDevice.current().identifier.archive())
            
            ///
            /// 5. We expect the houseHub identifier back.
            ///
            data = Data(capacity: MemoryLayout<HouseIdentifier>.size)
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                Log.fatal("Ext - Timeout waiting for house identifier back", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            
            guard let houseIdentifier = HouseIdentifier.unarchive(data) else {
                throw HNCP.Error.FailedHNCP(message: "Unable to unarchive HouseIdentifier data")
            }
            guard houseIdentifier == HouseIdentifier.hub else {
                throw HNCP.Error.FailedHNCP(message: "Not communicating with a HouseHub")
            }
            Log.debug("Ext - Recieved identifier \(houseIdentifier)", in: .networkHandshake)
            
            ///
            /// 6. We now send our category bit masks.
            ///
            let supportedCategories = HouseDevice.current().categoryDelegate.supportedCategories()
            let bitmasks = HouseCategory.bitmasks(from: supportedCategories)
            let bitmasksData = bitmasks.reduce(Data(), { (data, bitmask) -> Data in
                return data + bitmask.archive()
            })
            try socket.write(from: bitmasksData)
            Log.debug("Ext - Sending Bitmasks", in: .networkHandshake)
            
            ///
            /// 7. We expect to recieve complete back.
            ///
            data = Data(capacity: 1)
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            
            guard let confData = data.remove(forType: UInt8.self) else {
                throw HNCP.Error.FailedHNCP(message: "Could not retrieve conf data")
            }
            guard let conf = UInt8.unarchive(confData) else {
                throw HNCP.Error.FailedHNCP(message: "Could not unarchive conf data")
            }
            guard conf == HNCP.complete else {
                throw HNCP.Error.FailedHNCP(message: "Conf did not match HNCP")
            }
            
            ///
            /// 8. We send back complete!
            ///
            Log.debug("Ext - Sending completion", in: .networkHandshake)
            try socket.write(from: HNCP.complete.archive())
            
            // Wasn't so hard now, was it?
            return HandshakeResponse(.success, identifier: houseIdentifier, role: .houseHub)
        }
        catch {
            Log.warning("Failed handshake. Reason: \(error)", in: .networkHandshake)
            return HandshakeResponse(.failed)
        }
    }
    
    public func close() {
        self.houseDevices.stopAll()
    }
    
    public func didRecieveNewMessage(for recipient: HouseIdentifier) {
        self.writeLock.sync {
            while let newMessage = HouseDevice.current().messageOutbox.pop(for: recipient) {
                if !self.houseDevices.forward(message: newMessage.message) {
                    Log.debug("Failed to clear backlog.", in: .network)
                    HouseDevice.current().messageOutbox.backlog(message: newMessage)
                    return
                }
            }
        }
    }
    
}
