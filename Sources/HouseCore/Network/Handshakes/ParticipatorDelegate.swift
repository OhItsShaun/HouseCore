//
//  HouseSocketResponder.swift
//  House
//
//  Created by Shaun Merchant on 18/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket 

/// Functionality needed to
public protocol HouseNetworkParticipatorDelegate: class {
    
    /// Determine if a connection is part of the House Network, and delegate accordingly.
    ///
    /// - Parameter socket: The socket which holds the connection.
    func handleNewConnection(using socket: Socket)
    
    /// Perform the handshake with a socket.
    ///
    /// - Parameter socket: A socket to handshake.
    /// - Throws: An error that has been encountered during the handshake.
    func performHandshake(with socket: Socket) -> HandshakeResponse
    
    /// Close any active processes in the participator immediately.
    func close()
    
}
