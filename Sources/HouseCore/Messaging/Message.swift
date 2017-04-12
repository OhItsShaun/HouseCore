//
//  Message.swift
//  House
//
//  Created by Shaun Merchant on 14/08/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable

/// A `Message` is data to be transmitted across the House Network.
public struct Message {
    
    /// The recipient of the message.
    public var recipient: HouseIdentifier
    
    /// The priority of the message.
    public var priority: Priority = .normal
    
    /// The bit contents of the message.
    public var bundle: ServiceBundle
    
    /// Create a new message.
    ///
    /// - Parameters:
    ///   - priority: The priority of the message.
    ///   - recipient: The intended recipient of the message.
    ///   - bundle: The contents of the message.
    public init(to recipient: HouseIdentifier, priority: Priority = .normal, bundle: ServiceBundle) {
        self.priority = priority
        self.recipient = recipient
        self.bundle = bundle
    }
    
    /// The importance of a Message. Messages of greater importance are more likely to take priority in transmission.
    ///
    /// - important: Do **not** use `.safetyCritical` carelessly. It must only be used for genuine safety critical messages.
    public enum Priority: UInt8 {
        
        /// A regular message.
        case normal = 0
        
        /// A message that pertains to the health and safety of occupants.
        case safetyCritical = 1
    }
    
}

// MARK: - Priority Archive
extension Message.Priority: Archivable {
    
    public func archive() -> Data {
        return Data(from: self)
    }
    
}

// MARK: - Priority Unarchive
extension Message.Priority: Unarchivable {
    
    public static func unarchive(_ data: Data) -> Message.Priority? {
        guard let rawValue = UInt8.unarchive(data) else {
            return nil
        }
        
        return Message.Priority(rawValue: rawValue)
    }
    
}

extension Message.Priority: Equatable {
    
    public static func ==(lhs: Message.Priority, rhs: Message.Priority) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}

extension Message.Priority: Comparable {
    
    public static func <(lhs: Message.Priority, rhs: Message.Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func <=(lhs: Message.Priority, rhs: Message.Priority) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    
    public static func >=(lhs: Message.Priority, rhs: Message.Priority) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
    
    public static func >(lhs: Message.Priority, rhs: Message.Priority) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
    
}

extension Message: Archivable {
    
    
    /// Convert a Message into an archiveable format.
    ///
    /// An archived message has the format of:
    /// - Priority, `UInt8`
    /// - The recipient of the message, `HouseIdentifier`
    /// - The amount of data in the message as `UInt16`
    /// - The data in the message as `ServiceBundle`
    ///
    /// - Returns: The message in an archiveable format.
    public func archive() -> Data {
        var data = Data()
        data.append(self.priority.archive())
        data.append(self.recipient.archive())
        
        let bundleData = self.bundle.archive()
        
        data.append(UInt16(bundleData.count).archive())
        data.append(bundleData)
        
        return data
    }
    
}

extension Message: Unarchivable {
    
    public static func unarchive(_ data: Data) -> Message? {
        guard let (message, _) = Message.progressiveUnarchive(data) else {
            return nil
        }
            
        return message
    }
    
    
    /// Given a collection of data that could contain at least 0 messages, and at most an infinite amount of messages
    /// attempt to unarchive and return a message in the collection of data and the collection of data that remains,
    /// which could be part of a message, or multiple messages, that has yet to be recieved in full.
    ///
    /// - Parameter data: The collection of archive messages to unarchive.
    /// - Returns: The message successfully unarchived and remaining data, or `nil` in the case there is no remaining 
    ///            data, or a message could not be unarchived.
    public static func progressiveUnarchive(_ data: Data) -> (Message, Data?)? {
        var data = data
        
        //
        // Unarchive Priority
        //
        guard let priorityData = data.remove(forType: Message.Priority.RawValue.self), let priority = Message.Priority.unarchive(priorityData) else {
            Log.warning("Could not unarchive priority.", in: .networkMessages)
            return nil
        }
        
        //
        // Unarchive Recipient
        //
        guard let recipientData = data.remove(forType: HouseIdentifier.self), let recipient = HouseIdentifier.unarchive(recipientData) else {
            Log.warning("Could not unarchive recipient.", in: .networkMessages)
            return nil
        }
        
        //
        // Unarchive Data Count
        //
        guard let dataCountData = data.remove(forType: UInt16.self), let dataCount = UInt16.unarchive(dataCountData) else {
            Log.warning("Could not unarchive data count.", in: .networkMessages)
            return nil
        }
        
        //
        // Unarchive Data
        //
        guard let bundleData = data.remove(to: MemoryLayout<UInt8>.size * Int(dataCount)) else {
            Log.warning("Data underflow.", in: .networkMessages)
            return nil
        }
        
        guard let serviceBundle = ServiceBundle.unarchive(bundleData) else {
            Log.warning("Could not unarchive service.", in: .networkMessages)
            return nil
        }
        
        // 
        // Create message
        //
        let message = Message(to: recipient, priority: priority, bundle: serviceBundle)
        
        guard data.count == 0 else {
            Log.debug("Multiple packets unarchived. Progressive triggered.", in: .networkMessages)
            return (message, data)
        }
        
        return (message, nil)
    }
    
}

extension Message: CustomStringConvertible {
    
    public var description: String {
        get {
            return "Message(to: \(self.recipient), priority: \(self.priority), bundle: \(self.bundle))"
        }
    }
    
}

extension Message: Equatable {
    
    public static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.bundle == rhs.bundle && lhs.priority == rhs.priority && lhs.recipient == rhs.recipient
    }

}
