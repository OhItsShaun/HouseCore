//
//  HouseDeviceWorker.swift
//  House
//
//  Created by Shaun Merchant on 26/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket
#if os(Linux)
    import Dispatch
#endif

/// An instance of `HouseDeviceWorker` reads HNCP-conforming messages from a House Device
/// and places them into the device's inbox for delegation to internal services.
public class HouseDeviceWorker {
    
    /// The identifier of the House Device the worker is interacting with.
    fileprivate var houseIdentifier: HouseIdentifier
    
    /// The HouseDevice socket for us to service.
    private var socket: Socket
    
    /// The read queue.
    private let socketDispatch: DispatchQueue
    
    /// The read queue.
    private let serviceDispatch: DispatchQueue = DispatchQueue(label: "serviceDispatch", qos: .utility)
    
    /// Whether or not the worker is currently servicing the HouseDevice.
    private(set) public var running: Bool
    
    /// The last time contact was made with the device.
    private(set) public var lastContact: Date
    
    /// Create a HouseDeviceWorker to service a HouseDevice.
    ///
    /// - Parameters:
    ///   - houseSocket: A socket to a known HouseDevice to service.
    ///   - dispatch: The read queue to handle reading of the socket.
    public init(for houseIdentifier: HouseIdentifier, usingSocket houseSocket: Socket, onDispatch dispatchQueue: DispatchQueue) {
        self.houseIdentifier = houseIdentifier
        self.socket = houseSocket
        self.socketDispatch = dispatchQueue
        self.running = false
        self.lastContact = Date.distantPast
    }
    
    /// Start the HouseDeviceWorker to read messages from the HouseDevice until `stop()` or the socket closes.
    public func start() {
        Log.debug("Starting HouseDeviceWorker for: \(self.houseIdentifier)", in: .networkMessagesWorker)
        self.running = true
        
        self.socketDispatch.async {
            self.beginReading(from: self.socket)
        }
    }
    
    /// Stop the HouseDeviceWorker from reading messages.
    /// 
    /// - Important: This does not shut down the socket nor immediately stop messages from being serviced.
    ///              The current data being pushed through the socket will be accepted before termination.
    public func stop() {
        Log.debug("Stopping HouseDeviceWorker for: \(self.houseIdentifier)", in: .networkMessagesWorker)
        self.running = false
        self.socket.close()
    }
    
    /// Begin reading data from the socket.
    ///
    /// - Parameter socket: The socket to read from.
    internal func beginReading(from socket: Socket) {
        self.readMessages(from: socket, into: forwardToMessageInboxDelegate)
    }
    
    /// Read messages from a HouseSocket.
    ///
    /// - Parameter socket: The socket to read messages from.
    internal func readMessages(from socket: Socket, into inbox: (Message) -> ()) {
        var buffer = Data(capacity: 4096)
        
        do {
            while !socket.remoteConnectionClosed && self.running {
                // Wait for data
                guard let _ = try Socket.wait(for: socket, timeout: 30000) else {
                    Log.debug("No message recieved within 30 seconds.", in: .networkMessagesWorker)
                    if self.lastContact.addingTimeInterval(30) < Date() {
                        Log.debug("No contact recieved within 30 seconds. Closing socket to preserve resources.", in: .networkMessagesWorker)
                        self.stop()
                        break
                    }
                    else {
                        continue
                    }
                }
                
                guard try socket.read(into: &buffer) > 0 && buffer.count > 0 else {
                    Log.debug("No data recieved. Continuing round...", in: .networkMessagesWorker)
                    continue
                }
                
                HouseNetwork.current().lastContact = Date()
                self.lastContact = Date()
                
                while buffer.count > 0 {
                    guard let (message, leftOver) = Message.progressiveUnarchive(buffer) else {
                        break
                    }
                    
                    if let data = leftOver {
                        buffer = data
                    }
                    else {
                        buffer = Data(capacity: 4096)
                    }
                    
                    inbox(message)
                }
            }
        }
        catch let error {
            Log.fatal("Error in service: \(error)", in: .networkMessagesWorker)
        }
        
        Log.debug("Stopping HouseDeviceWorker reading for: \(self.houseIdentifier)", in: .networkMessagesWorker)
        socket.close()
        self.running = false
    }
    
    /// Write a message to the socket.
    ///
    /// - Parameter message: The message to write to socket.
    /// - Returns: Whether or not writing the message was successful.
    public func write(message: Message) -> Bool {
        Log.debug("Writing message: \(message) to: \(self.houseIdentifier)", in: .networkMessagesWorker)
        
        do {
            try self.socket.write(from: message.archive())
            
            HouseNetwork.current().lastContact = Date()
            self.lastContact = Date()
    
            return true
        }
        catch {
            Log.fatal("Error in writing server: \(error)", in: .networkMessagesWorker)
            return false
        }
    }
    
    /// Forward a message to HouseDevice's MessageInboxDelegate.
    ///
    /// - Parameter message: The message to forward.
    internal func forwardToMessageInboxDelegate(message: Message) {
        self.serviceDispatch.async {
            Log.debug("Recieved message: \(message) from: \(self.houseIdentifier)", in: .networkMessagesWorker)
            HouseDevice.current().messageInbox.recieved(message: message)
        }
    }
    
    deinit {
        Log.debug("Deinitialising HouseDeviceWorker for: \(self.houseIdentifier)", in: .networkMessagesWorker)
        self.stop()
    }
    
}
