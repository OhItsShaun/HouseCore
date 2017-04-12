//
//  MessageOutbox.swift
//  House
//
//  Created by Shaun Merchant on 08/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
import DataStructures
#if os(Linux)
    import Dispatch
#endif

/// A sequential list of messages that waiting to be transmitted across the houseNetwork.
public class MessageOutbox: MessageOutboxDelegate {

    /// The collection of stored messages.
    private var messageStore = MessageCollection()
    
    public var outboxResponderDelegate: MessageOutboxResponderDelegate? = nil
    
    public func add(message: Message, expiresAt expiraryTime: Date) {
        let pendingMessage = PendingMessage(message, expiresAt: expiraryTime)
        self.messageStore.add(message: pendingMessage)
        
        self.outboxResponderDelegate?.didRecieveNewMessage(for: message.recipient)
    }

    public func pop(for houseIdentifier: HouseIdentifier) -> PendingMessage? {
        return self.messageStore.pop(for: houseIdentifier)
    }
    
    public func backlog(message: PendingMessage) {
        self.messageStore.add(message: message)
    }
    
    /// A collection of queued messages, organised by message priority.
    private struct MessageCollection {

        /// A collection of queues.
        private var backlog: [HouseIdentifier: PriorityQueue<PendingMessage>] = [:]
        
        /// An upper bound on the number of messages yet to be sent. 
        ///
        /// - Important: This is in an upper bound as messages in the queues could have expired.
        public var upperBound: Int {
            get {
                return self.backlog.reduce(0, { (count, messages: (key: HouseIdentifier, value: PriorityQueue<PendingMessage>)) -> Int in
                    return count + messages.value.count
                })
            }
        }
        
        /// A write lock used to ensure concurrency safety.
        ///
        /// - Important: Anytime `messageStore` is mutated, to ensure concurrency safety `writeLock.sync { ... }` **should** be used.
        private let writeLock = DispatchQueue(label: "houseNetwork.messageQueue.writeLock", qos: .userInitiated)
        
        /// Instance a new Message Collection.
        init () {
            
        }
        
        /// Add a message to the queue.
        ///
        /// - Parameters:
        ///   - message: The message to send across the houseNetwork.
        ///   - atTime: When the message should expire, default is 1 day.
        ///
        /// - Complexity: Amortized O(1) over many additions.
        public mutating func add(message: PendingMessage) {
            self.writeLock.sync {
                if self.backlog[message.message.recipient] == nil {
                    self.backlog[message.message.recipient] = PriorityQueue<PendingMessage>()
                }
                
                self.backlog[message.message.recipient]?.insert(message)
            }
            Log.debug("Added Message: \(message). Upperbound: \(self.upperBound).", in: .messageOutbox)
        }
        
        /// Remove and return the next message to be sent from the queue.
        ///
        /// - Parameter houseIdentifier: The House Identifier to retrieve the next message for, `nil` if no messages are available for the House Device.
        /// - Returns: The next message to be sent from the queue.
        public mutating func pop(for houseIdentifier: HouseIdentifier) -> PendingMessage? {
            defer {
                Log.debug("Attempted to pop for \(houseIdentifier). Upperbound: \(self.upperBound).", in: .messageOutbox)
            }
            
            return self.writeLock.sync {
                let scanStart = Date()
                
                while let nextMessage = self.backlog[houseIdentifier]?.pop() {
                    if nextMessage.expiraryTime > scanStart {       // If it hasn't expired...
                        return nextMessage                              // Return that message
                    }
                    else {
                        continue                                    // Otherwise discard it and contiue.
                    }
                }
                
                return nil
            }
        }
        
    }

}
