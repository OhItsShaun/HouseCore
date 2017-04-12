//
//  BeaconEmitter.swift
//  House
//
//  Created by Shaun Merchant on 23/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// Listens to House beacons, emitted by houseHub.
public class HouseBeaconListener: MulticastBeaconListenerDelegate {
    
    public var socket: Socket? = nil

    public var connectionHandler: ((Socket) -> ())? = nil
    
    public func join() {
        self.socket?.close()
        self.socket = self.join(group: HNCP.multicastGroup, on: HNCP.multicastPort)
    }
    
    public func perform() {
        if let socket = self.socket, socket.isListening {
            return
        }
        
        self.join()
        self.listen()
    }
    
    public func listen() {
        guard let connectionHandler = self.connectionHandler else {
            Log.debug("Could not listen as no responder was declared.", in: .networkBeacon)
            return
        }
        
        let predicate: (Data) -> Bool = { data in
            // Guard the datagram is decodeable.
            guard let message = String(data: data, encoding: .utf8) else {
                Log.debug("Datagram undecodable.", in: .networkBeacon)
                return false
            }
            
            // Guard the datagram is a House beacon.
            guard message == HNCP.multicastMessage else {
                Log.debug("Datagram not House, message: \(message).", in: .networkBeacon)
                return false
            }
            
            return true
        }
        
        let responder: (String) -> () = { hostname in
            do {
                let socket = try Socket.create()
                try socket.connect(to: hostname, port: HNCP.hubListeningPort)
                
                connectionHandler(socket)
            }
            catch {
                Log.debug("Error responding to beacon sender: \(error)", in: .networkBeacon)
            }
            
        }
        
        self.listenForPackets(matchingPredicate: predicate, senderHandler: responder)
    }
    
    deinit {
        Log.debug("Beacon deinit..", in: .networkBeacon)
        self.stop()
    }
}
