//
//  MulticastBeaconDelegate.swift
//  House
//
//  Created by Shaun Merchant on 23/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket 

/// A utility to handle multicast packets.
public protocol MulticastBeaconDelegate: class {
    
    /// The socket that is listening to the multicast group, nil otherwise.
    var socket: Socket? { get set }
    
    /// Perform any setup necessary, such as joining the multicast group.
    func join()
    
    /// Perform any behaviour necessary for the beacon's purpose. Periodically called.
    func perform()
    
    /// Stop all processes within the multicast beacon.
    func stop()
    
}

/// A utility to listen to packets from a multicasting group.
public protocol MulticastBeaconListenerDelegate: MulticastBeaconDelegate {
    
    /// A closure to call for sockets established with appropriate packets.
    var connectionHandler: ((Socket) -> ())? { get set }
    
    /// Listen for packets send to the multicast group.
    func listen()
    
}

/// A utility to emit packets to a multicasting group.
public protocol MulticastBeaconEmitterDelegate: MulticastBeaconDelegate {
    
    /// Emit a packet(s) to the multicast group.
    func emit()
    
}

extension MulticastBeaconDelegate {
    
    /// Join a multicasting group.
    ///
    /// - Parameters:
    ///   - group: The group to join.
    ///   - port: The port to join.
    /// - Returns: A socket if the multicast group could be joined, nil otherwise.
    public func join(group: String, on port: UInt16) -> Socket? {
        do {
            let socket = try Socket.create(type: .datagram, proto: .udp)
            try socket.enableAddressReuse()
            try socket.bind(to: port)
            try socket.joinMulticast(group: group)
            
            return socket
        }
        catch {
            Log.warning("Error: \(error)", in: .networkBeacon)
        }
        
        return nil
    }
    
    public func stop() {
        self.socket?.close()
    }
    
}

extension MulticastBeaconListenerDelegate {
    
    
    /// Listen for packets using the multicast socket.
    ///
    /// - Parameters:
    ///   - predicate: A predicate to determine if the packet should be forwarded to the host handler.
    ///   - senderHandler: A closure to respond to the hostname of the sender that a packet that satisfied the predicate.
    public func listenForPackets(matchingPredicate predicate: (Data) -> Bool, senderHandler: (String) -> ()) {
        guard let socket = self.socket else {
            Log.debug("Cannot listen for packets if socket does not exist.", in: .networkBeacon)
            return
        }
        do {
            repeat {
                var data = Data(capacity: 128)
                
                Log.debug("Listening to beacon...", in: .networkBeacon)
                let (read, addressAttempt) = try socket.readDatagram(into: &data)
                
                // Guard we have recieved data
                guard read > 0 else {
                    continue
                }
                
                // From a valid address
                guard let address = addressAttempt else {
                    Log.warning("Recieved datagram (size: \(read), data: \(data)) from unknown address", in: .networkBeacon)
                    continue
                }
                
                // And the datagram is decodeable
                guard predicate(data) else {
                    Log.warning("Recieved undecodable datagram from: \(address)", in: .networkBeacon)
                    continue
                }
                
                // And that we can resolve the sender
                guard let datagramSender = Socket.hostnameAndPort(from: address) else {
                    Log.warning("Unable to resolve host from datagram", in: .networkBeacon)
                    continue
                }
                
                Log.debug("Device discovered at: \(datagramSender.hostname)", in: .network)
                senderHandler(datagramSender.hostname)
            } while socket.isListening
        }
        catch {
            Log.warning("Error: \(error)", in: .networkBeacon)
            self.socket?.close()
        }
    }
}

extension MulticastBeaconEmitterDelegate {
    
    /// Establish a socket to a given address and write data to the socket via UDP.
    ///
    /// - Parameters:
    ///   - data: The data to write to the socket via UDP.
    ///   - address: The address to establish a socket to.
    public func emit(data: Data, to address: Socket.Address) {
        do {
            Log.debug("Broadcasting... \(Date())", in: .networkBeacon)
            try self.socket?.write(from: data, to: address)
        }
        catch {
            Log.warning("Broadcasting Error.", in: .networkBeacon)
        }
    }
    
    /// Establish a socket to a given address and write a string, encoded as UTF-8, to the socket via UDP.
    ///
    /// - Parameters:
    ///   - data: The string, encoded as UTF-8, to write to the socket via UDP.
    ///   - address: The address to establish a socket to.
    public func emit(message: String, to address: Socket.Address) {
        guard let messageData = message.data(using: .utf8) else {
            Log.fatal("Unable to encode message beacon", in: .networkBeacon)
            return
        }
        
        self.emit(data: messageData, to: address)
    }

}
