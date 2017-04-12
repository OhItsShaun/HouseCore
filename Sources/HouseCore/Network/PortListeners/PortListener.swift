//
//  HouseNetworkListenerDelegate.swift
//  House
//
//  Created by Shaun Merchant on 23/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket

/// Conformants to `PortListenerDelegate` listen to a port on the machine for incoming socket connections
public protocol PortListenerDelegate: class {
    
    /// Whether or not the delegate is actively listening for incoming connections.
    var isListening: Bool { get }
    
    /// The socket the delegate is listening for connections over.
    var listeningSocket: Socket? { get set }
    
    /// Start listening for connections.
    func listen()
    
    /// Handle a socket that has made an inbound connection.
    ///
    /// - Parameter socket: The socket that has made an inboud connection.
    func handleNewConnection(with socket: Socket)
    
    /// Stop all processes of the listener delegate.
    func stop()
}

public extension PortListenerDelegate {
    
    /// Whether the delegate has binded to, and listening on, the port.
    public var isListening: Bool {
        get {
            guard let socket = self.listeningSocket else {
                return false
            }
            
            return socket.isListening
        }
    }
    
    /// Listen to connections over a port.
    ///
    /// - Important: The function will only return when it is no longer listening for inbound connections.
    ///
    /// - Parameter port: The port to listen to connections over.
    public func listen(on port: Int) {
        guard !self.isListening else {
            return
        }
        
        do {
            self.listeningSocket = try Socket.create()
            
            guard let socket = self.listeningSocket else {
                Log.fatal("Unable to create listening socket.", in: .network)
                return
            }
        
            try socket.listen(on: port)
            
            repeat {
                Log.debug("Listening for incoming connection...", in: .network)
                let newSocket = try socket.acceptClientConnection()
                
                Log.debug("Recieved device connection (\(newSocket.remoteHostname)).", in: .network)
                self.handleNewConnection(with: newSocket)
            } while socket.isListening
        }
        catch {
            Log.warning("Error: \(error)", in: .portListener)
        }
    }
    
    public func stop() {
        self.listeningSocket?.close()
    }
    
}
