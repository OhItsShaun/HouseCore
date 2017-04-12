//
//  InitiatorParticipator.swift
//  House
//
//  Created by Shaun Merchant on 18/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

//TODO: Move to Hub side of things.

import Foundation
import Socket
#if os(Linux)
    import Dispatch
#endif

/// A delegate to allow a House Hub to participate in the House Network.
final class HouseNetworkInitiatorParticipator: HouseNetworkParticipatorDelegate, MessageOutboxResponderDelegate {
    
    /// Known devices and their connectors.
    private var houseDevices = HouseDeviceConnectors()
    
    /// A lock on messages.
    fileprivate var writeLock = DispatchQueue(label: "houseNetwork.writeLock", qos: .userInitiated)
    
    /// Create a new House Network delegate for a house Hub to participate in the House Network.
    /// The outbox of the current House Device will be set to route messages through the instanced
    /// delegate.
    init() {
        HouseDevice.current().messageOutbox.outboxResponderDelegate = self
    }
    
    public func handleNewConnection(using socket: Socket) {
        Log.debug("Recieved device connection (\(socket.remoteHostname)). Handling connection...", in: .network)
        
        let response = self.performHandshake(with: socket)
        guard response.status == .success, let houseIdentifier = response.houseIdentifier else {
            Log.debug("Device connection (\(socket.remoteHostname)) failed handshake", in: .network)
            socket.close()
            return
        }
        
        //MARK
//        if HouseDevice.current().role == .houseHub {
//            let device = HouseExtension(houseIdentifier)
//            if let categories = response.supportedCategories {
//                for category in categories {
//                    device.enableSupport(for: category)
//                }
//            }
//            Log.debug("Adding House Extension: \(device)", in: .network)
//            House.extensions.addExtension(device)
//        }
        
        Log.debug("Device connection (\(socket.remoteHostname)) succeeded handshake.", in: .network)
        self.houseDevices.updateConnector(address: socket.remoteHostname, activeSocket: socket, for: houseIdentifier)
    }
    
    internal func performHandshake(with socket: Socket) -> HandshakeResponse {
        do {
            ///
            /// 1. We send HNCP.initiation
            ///
            Log.debug("Hub - Sending Initiaton", in: .networkHandshake)
            try socket.write(from: HNCP.initiation.archive())
            
            ///
            /// 2. We recieve HNCP.acknolwedgement and HNCP.version
            ///
            var data = Data(capacity: 2)
            var bytesRead: Int = 0
            
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                Log.fatal("Hub - Timeout waiting for ACK+VER", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                Log.fatal("Hub - No bytes read for ACK+VER", in: .networkHandshake)
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            
            guard let ackData = data.remove(forType: UInt8.self) else {
                throw HNCP.Error.FailedHNCP(message: "Unable to remove ACK Data")
            }
            guard let ack = UInt8.unarchive(ackData) else {
                throw HNCP.Error.FailedHNCP(message: "Unable to unarchive ACK Data")
            }
            guard let version = UInt8.unarchive(data) else {
                throw HNCP.Error.FailedHNCP(message: "Unable to unarchive version Data")
            }
            
            Log.debug("Hub - Recieved ack \(ack)", in: .networkHandshake)
            guard ack == HNCP.acknowledgement else {
                throw HNCP.Error.FailedHNCP(message: "ACKs did not match")
            }
            
            Log.debug("Hub - Recieved version \(version)", in: .networkHandshake)
            guard version == HNCP.version else {
                Log.fatal("Hub - Failed HNCP Version", in: .networkHandshake)
                throw HNCP.Error.FailedHNCP(message: "Unsupported HNCP version")
            }
            
            ///
            /// 3. We send HNCP.versionAcceptance
            ///
            Log.debug("Hub - Sending version acceptance", in: .networkHandshake)
            try socket.write(from: HNCP.versionAcceptance.archive())
            
            ///
            /// 4. We recieve unique identifier
            ///
            data = Data(capacity: MemoryLayout<HouseIdentifier>.size)
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                Log.fatal("Hub - Timeout waiting for HouseIdentifier", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                Log.fatal("Hub - No bytes read for unique identifier", in: .networkHandshake)
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            
            guard let houseIdentifier = HouseIdentifier.unarchive(data) else {
                throw HNCP.Error.FailedHNCP(message: "Unable to unarchive HouseIdentifier data")
            }
            Log.debug("Hub - Recieved house identifier \(houseIdentifier)", in: .networkHandshake)
            
            ///
            /// 5. We send back houseHub identifier.
            ///
            try socket.write(from: HouseIdentifier.hub.archive())
            
            ///
            /// 6. We expect categories back.
            ///
            let expectingBack = HouseCategory.all().count / 8 + 1
            data = Data(capacity: expectingBack)
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                Log.fatal("Hub - Timeout waiting for Bitmasks", in: .networkHandshake)
                throw HNCP.Error.Timeout
            }
            
            bytesRead = try socket.read(into: &data)
            if bytesRead == 0 {
                Log.fatal("Hub - No bytes read for bitmasks", in: .networkHandshake)
                throw HNCP.Error.UnexpectedFailedSocketRead
            }
            
            var bitmasks = [UInt8](repeating: 0b0, count: expectingBack)
            for index in 0..<expectingBack {
                guard let bitmaskData = data.remove(to: 1) else {
                    Log.warning("Did not recieve all bitmask for index: \(index)", in: .networkHandshake)
                    continue
                }
                guard let bitmask = UInt8.unarchive(bitmaskData) else {
                    Log.warning("Could not retrieve bitmask from Data: \(index)", in: .networkHandshake)
                    continue 
                }
                bitmasks[index] = bitmask
            }
            let categories = HouseCategory.categories(from: bitmasks)

            ///
            /// 7. We send complete.
            ///
            Log.debug("Hub - Sending complete", in: .networkHandshake)
            try socket.write(from: HNCP.complete.archive())
            
            ///
            /// 8. We expect to recieve complete back
            ///
            data = Data(capacity: 1)
            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
                Log.fatal("Hub - Timeout waiting for conf", in: .networkHandshake)
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
            Log.debug("Hub - Recieved complete", in: .networkHandshake)

            
            // Wasn't so hard now, was it?
            return HandshakeResponse(.success, identifier: houseIdentifier, role: .houseExtension, supportedCategories: categories)
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
