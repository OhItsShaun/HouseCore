//
//  MulticastParticipator.swift
//  House
//
//  Created by Shaun Merchant on 25/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// A structure to enable multicasting beacons.
public class HouseBeaconEmitter: MulticastBeaconEmitterDelegate {
    
    public var socket: Socket? = nil
    
    private var address: Socket.Address? = nil
    private let group = HNCP.multicastGroup
    private let port = Int32(HNCP.multicastPort)
    
    public func join() {
        do {
            self.socket = try Socket.create(type: .datagram, proto: .udp)
        }
        catch {
            Log.warning("Beacon Emitter Join Error: \(error)", in: .networkBeacon)
        }
    }
    
    public func perform() {
        if self.socket == nil {
            self.join()
        }
        
        guard socket != nil else {
            return
        }
        self.emit()
    }
    
    public func emit() {
        if self.address == nil {
            if let address = Socket.createAddress(for: self.group, on: self.port) {
                self.address = address
            }
            else {
                Log.fatal("Unable to attain address for beacon.", in: .networkBeacon)
                return
            }
        }
        
        guard let address = self.address else {
            return
        }
        
        self.emit(message: HNCP.multicastMessage, to: address)
    }
    
}
