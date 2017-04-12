//
//  MessageOutboxResponder.swift
//  House
//
//  Created by Shaun Merchant on 22/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A `MessageOutboxResponderDelegate` recieves notification when a new message has been added to a `MessageOutbox`.
public protocol MessageOutboxResponderDelegate {
    
    /// Notification that a new message has been added to the message queue.
    ///
    /// - Parameter recipient: Who the new message is for.
    ///
    /// - Important: Due to multithreading, notification does **not** guarantee a subsequent `pop()!` on an instance of `MessageOutbox` will be safe.
    func didRecieveNewMessage(for recipient: HouseIdentifier)
    
}
