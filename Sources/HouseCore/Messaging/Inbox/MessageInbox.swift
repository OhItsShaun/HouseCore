//
//  HouseMessagesControllerDelegate.swift
//  House
//
//  Created by Shaun Merchant on 10/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// Conformants act as an inbox for messages, delegating them across the
/// House Device and possibly the House Network. 
public protocol MessageInboxDelegate {
    
    /// Distribute a recieved message across the device and network where appropriate.
    ///
    /// - Parameter message: The message to distribute.
    func recieved(message: Message)
    
}

/// A standard implementation of a conformant to `MessageInboxDelegate`
public struct MessageInbox: MessageInboxDelegate {
    
    /// Distribute a recieved message across the House Device and House Network where appropriate.
    ///
    /// - Parameter message: The message to distribute.
    public func recieved(message: Message) {
        
        Log.debug("Inbox Recieved: (\(message)).", in: .messageInbox)
        
        // Guard that the message we've recieved is actually for us
        if HouseDevice.current().role == .houseHub {
            guard message.recipient == HouseIdentifier.hub || message.recipient == HouseDevice.current().identifier else {
                // Message is destined for another Extension. Forward it on.
                HouseDevice.current().messageOutbox.add(message: message)
                return
            }
        }
        else {
            guard message.recipient == HouseDevice.current().identifier else {
                Log.warning("Recieved message that wasn't intended for me. Discarding.", in: .messageInbox)
                return
            }
        }
    
        // Forward that message on.
        HouseDevice.current().packages.handle(bundle: message.bundle)

    }
    
}
