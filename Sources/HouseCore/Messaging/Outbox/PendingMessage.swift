//
//  PendingMessage.swift
//  House
//
//  Created by Shaun Merchant on 11/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A message that is yet to be transmitted across the House Network.
public struct PendingMessage {
    
    /// The message which expires.
    public let message: Message
    
    /// The timestamp of expirary, afterwhich the message should be discarded.
    public let expiraryTime: Date
    
    /// The timestamp of message creation.
    public let createdTime: Date
    
    /// Create a new expiring message.
    ///
    /// - Parameters:
    ///   - message: The message which expires.
    ///   - expiraryTime: The timestamp of expirary, afterwhich the message should be discarded.
    ///   - creationTime: The time at which the message was created.
    public init(_ message: Message, expiresAt expiraryTime: Date, createdAt creationTime: Date = Date()) {
        self.message = message
        self.expiraryTime = expiraryTime
        self.createdTime = creationTime
    }
    
}

extension PendingMessage: Equatable {
    
    
    public static func ==(lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        return lhs.message == rhs.message
    }
    
}
extension PendingMessage: Comparable {
    
    public static func <(lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        // Highest priority comes first..
        if lhs.message.priority < rhs.message.priority {
            return true
        }
        if lhs.message.priority > rhs.message.priority {
            return false
        }
        
        // This may seem counter intuitive, but we want messages 
        // that were created earlier to be greater priority. Therefore
        // if the time at which lhs < rhs then it means it is earlier,
        // and therefore greater than RHS.
        if lhs.createdTime > rhs.createdTime {
            return true
        }
        
        return false
    }
    
    public static func <=(lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        if lhs.message.priority < rhs.message.priority {
            return true
        }
        if lhs.message.priority > rhs.message.priority {
            return false
        }
        if lhs.createdTime >= rhs.createdTime {
            return true
        }
        
        return false
    }
    
    public static func >(lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        if lhs.message.priority > rhs.message.priority {
            return true
        }
        if lhs.message.priority < rhs.message.priority {
            return false
        }
        
        if lhs.createdTime < rhs.createdTime {
            return true
        }
        
        return false
    }
    
    public static func >=(lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        if lhs.message.priority > rhs.message.priority {
            return true
        }
        if lhs.message.priority < rhs.message.priority {
            return false
        }
        if lhs.createdTime <= rhs.createdTime {
            return true
        }
        
        return false
    }
    
    
}
