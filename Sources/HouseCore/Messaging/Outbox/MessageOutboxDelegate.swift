//
//  MessageOutboxDelegate.swift
//  House
//
//  Created by Shaun Merchant on 22/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// Conformants act as an outbox for messages, notifying delegates
/// of the House Network that messages are available for transmission.
public protocol MessageOutboxDelegate {
    
    /// A delegate to recieve notification that a new message has been added to the queue.
    ///
    /// - important: Please register
    var outboxResponderDelegate: MessageOutboxResponderDelegate? { get set }
    
    /// Add a message to the queue.
    /// Messages added to the queue will be automagically sent when next possible.
    ///
    /// - Parameters:
    ///   - message: The message to send across the houseNetwork.
    ///   - atTime: When, if needed, the message should expire and therefore not be sent.
    ///
    /// - Complexity: Amortized O(1) over many additions.
    func add(message: Message, expiresAt expiraryTime: Date)
    
    /// Remove and return the next message to be sent from the queue.
    ///
    /// - Returns: The next message to be sent from the queue.
    func pop(for houseIdentifier: HouseIdentifier) -> PendingMessage?
    
    /// Backlog a message that could not be delivered for attempted re-delivery if the device becomes available.
    ///
    /// - Parameter message: The message that could not be delivered.
    func backlog(message: PendingMessage)
    
}

public extension MessageOutboxDelegate {
    
    /// Add a message that expires after 1 minute.
    ///
    /// - Parameter message: The message to add.
    public func add(message: Message) {
        self.add(message: message, expiresAt: Date().addingTimeInterval(60))
    }

}
