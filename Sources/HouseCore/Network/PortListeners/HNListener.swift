//
//  HouseNetworkListener.swift
//  House
//
//  Created by Shaun Merchant on 23/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// A class that listens for potential connections for the houseNetwork.
public class HouseNetworkListener: PortListenerDelegate {
    
    public var listeningSocket: Socket? = nil
    
    /// A handler for inbound connections.
    public var connectionHandler: (Socket) -> ()
    
    /// Instance a new listener for potential House connections.
    ///
    /// - Parameter connectionHandler: A closure to handle incoming connections.
    init(forwardingConnectionsTo connectionHandler: @escaping (Socket) -> ()) {
        self.connectionHandler = connectionHandler
    }
    
    public func listen() {
        if HouseDevice.current().role == .houseHub {
            self.listen(on: Int(HNCP.hubListeningPort))
        }
        else {
            self.listen(on: Int(HNCP.extensionListeningPort))
        }
    }
    
    public func handleNewConnection(with socket: Socket) {
        self.connectionHandler(socket)
    }
    
    deinit {
        self.stop()
    }
    
}
