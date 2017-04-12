//
//  Log.swift
//  House
//
//  Created by Shaun Merchant on 13/08/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/// Log permits logging of messages during runtime, with fatal and warning messages written to disk when possible.
/// 
/// - Important: Debug messages are not output when the program is compiled for release, being automatically stripped out by the compiler.
///
public struct Log {
    
    /// Log a message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: The domain in which the message occured.
    public static func message(_ message: String, in domain: Log.Domain = .generic) {
        #if DEBUG
            guard domain.debugging else {
                return
            }
            Log.write("\(domain): " + message)
        #endif
    }
    
    /// Log a fatal message.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - domain: The domain in which the fatal message occured.
    public static func fatal(_ message: String, in domain: Log.Domain = .generic) {
        Log.write("⛔️ \(domain): " + message)
    }
    
    /// Log a warning.
    ///
    /// - Parameters:
    ///   - message: The warning to log.
    ///   - domain: The domain in which the warning occured.
    public static func warning(_ message: String, in domain: Log.Domain = .generic) {
       Log.write("⚠️ \(domain): " + message)
    }
    
    /// Log verbose messages (useful for debugging)
    ///
    /// - Parameters:
    ///   - message: The debugging message to log.
    ///   - domain: The domain in which the debugging message occured.
    public static func debug(_ message: String, in domain: Log.Domain = .generic) {
        #if DEBUG
            guard domain.debugging else {
                return
            }
            Log.write("🐞 \(domain): " + message)
        #endif
    }
    
    /// Store a pre-formatted message to Log.
    ///
    /// - Parameter message: The message to store.
    private static func write(_ message: String) {
        Swift.print("\(Date()) : " + message)
    }
    
    
    /// The domain to log a message in.
    public enum Domain: String {
        /// A log informing of a generic event.
        case generic = "Uknown"
        
        /// A log informing of an automation event.
        case automation = "Automation"
        
        /// A log informing of a boot event.
        case boot = "Boot"
        
        /// A log informing of an extension process event.
        case extensionProcess = "Extension Process"
        
        /// A log informing of a port listening event.
        case portListener = "Port Listener"
        
        /// A log informing of a network event.
        case network = "Network"
        
        /// A log informing of a network messaging event.
        case networkMessages = "Network Message"
        
        /// A log informing of a network message worker event.
        case networkMessagesWorker = "HouseDeviceWorker"
        
        /// A log informing of a House Network event.
        case networkHouse = "Network House"
        
        /// A log informing of a network beacon event.
        case networkBeacon = "Network Beacon"
        
        /// A log informing of a network handshake event.
        case networkHandshake = "Network Handshake"
        
        /// A log informing of a hue network event.
        case hueNetwork = "Hue Network"
        
        /// A log informing of a connected device event.
        case connectedDevices = "Connected Devices"
        
        /// A log informing of a message inbox event.
        case messageInbox = "Message Inbox"
        
        /// A log informing of a message outbox event.
        case messageOutbox = "Message Outbox"
        
        /// A log informing of a package registry event.
        case packageRegistry = "Package Registry"
        
        /// A log informing of a standard package event.
        case standardPackages = "Standard Packages"
        
        /// A package reserved for debugging purposes.
        case debugPackage = "Debug Package"
        
        /// A log informing of a category event.
        case category = "Category Service"
        
        /// A log informing of a shell event.
        case shell = "Shell"
        
        /// A log informing of a house device event.
        case houseDevice = "House Device"
        
        /// A log informing of an astrological time event.
        case timeAstronomical = "Time Astronomy"
        
        /// A log informing of a URL request event.
        case urlRequest = "URL Request"
        
        /// A log informing of a HTTP request event.
        case httpRequest = "HTTP Request"
        
        /// A log informing of a file manager event.
        case fileManager = "File Manager"
        
        /// A log informing of a house structure event.
        case houseStructs = "House Structures"
        
        /// A log informing of an event event. Yeah. Mad right?
        case events = "Events"
        
        /// A log informing of a JSON event.
        case json = "JSON"
        
        /// A log informing of a Hue Device event.
        case hueDevice = "Hue Device"
        
        /// A log informing of an archive event.
        case archive = "Archive"
        
        /// Whether debugging is enabled for the domain.
        var debugging: Bool {
            switch self {
//            case .category: return true
//                        case .standardPackages: return true
//            case .standardPackages: return false
//            case .timeAstronomical: return false
//            case .automation: return true
//            case .urlRequest: return true
////            case .network: return false
//            case .packageRegistry: return false
//            case .boot: return false
            case .debugPackage: return true
            default: return false
            }
        }
    }
}
