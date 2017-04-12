//
//  HouseDevice.swift
//  House
//
//  Created by Shaun Merchant on 12/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation

/// `HouseDevice` provides a singleton instance representing the current houseDevice.
/// Through `HouseDevice` information about the device such as its role in the houseNetwork,
/// its house identifier, the house categories it supports and its message inbox and outbox.
public class HouseDevice {
    
    //MARK: - Static Holders
    
    /// The internal object link to the houseHub.
    /// By default `HouseHub` is lazy evaluated.
    internal static var _houseDevice: HouseDevice! = nil
    
    /// Create a HouseDevice with main delegate.
    ///
    /// - Parameter delegate: The main delegate.
    public static func create(with delegate: HouseProcess, using houseIdentifier: HouseIdentifier? = nil, as role: HouseDevice.Role = .houseExtension) {
        self._houseDevice = HouseDevice(with: delegate, using: houseIdentifier)
        HousePackages.initialiseEverything(to: self._houseDevice.packages)
    }
    
    /// Returns the shared object link to the current houseHub.
    ///
    /// - note: In order to ensure there is only ever one link to the houseHub we instance a HouseHub object as a private static variable, `_hubLink`, which we never make publicly available. Instead we use `current()` to return a reference to the variable, or instance a HouseHub object if it is not already created.
    ///
    ///
    /// - important: `create(with: HouseDelegate)` must be called before `current()` is called. Standard implmentation handles this for you.
    ///
    /// - Returns: The shared object link to the current houseHub.
    public static func current() -> HouseDevice {
        return HouseDevice._houseDevice
    }
    
    //MARK: - Initialiser
    
    /// Create a new House Device.
    ///
    /// - Parameters:
    ///   - delegate: The delegate that acts as the main process of the device.
    ///   - houseIdentifier: The House Identfier of the device.
    public init(with delegate: HouseProcess, using houseIdentifier: HouseIdentifier? = nil, as role: HouseDevice.Role = .houseExtension) {
        
        // Set the architecture
        if MemoryLayout<Int>.size == MemoryLayout<Int64>.size {
            self.architecture = HouseDevice.Architecture.bit64
        }
        else if MemoryLayout<Int>.size == MemoryLayout<Int32>.size {
            self.architecture = HouseDevice.Architecture.bit32
        }
        else {
            self.architecture = HouseDevice.Architecture.unknown
        }
        
        // Set the delegate
        self.mainDelegate = delegate
        
        // Set the House Identifier
        if let houseIdentifier = houseIdentifier {
            self.identifier = houseIdentifier
        }
        else {
            if let houseIdentifierString = Cache.retrieveValue(forKey: "houseIdentifier"), let houseIdentifier = HouseIdentifier(houseIdentifierString) {
                Log.debug("Retrieved HouseIdentifier from cache (\(houseIdentifier))", in: .houseDevice)
                self.identifier = houseIdentifier
            }
            else {
                let houseIdentifier = HouseIdentifier.random()
                Log.debug("No previous houseIdentifier found. Created new identifier: (\(houseIdentifier))", in: .houseDevice)
                
                self.identifier = houseIdentifier
                
                Cache.storeValue(String(houseIdentifier), forKey: "houseIdentifier")
                Cache.save()
            }
        }
        
        // Set the role
        self.role = role 
    }
    
    //MARK: - House Identifier
    
    /// The houseDevice's unique identifier.
    ///
    /// - important: As defined in the HNCP specification the unique device identifier (UDI) should **not** change across the lifetime of the device.
    ///              A change in the UDI will be treated by house as a "new" houseDevice.
    ///
    private(set) public var identifier: HouseIdentifier = 0 {
        didSet {
            Log.debug("Did set House Identifier to: \(self.identifier)", in: .houseDevice)
        }
    }
    
    //MARK: - Role
    
    /// The role of the House Device.
    private(set) public var role: HouseDevice.Role {
        didSet {
            Log.debug("Didset House Role to: \(self.role)", in: .houseDevice)
        }
    }
    
    /// The device's role in the houseNetwork.
    public enum Role {
        
        /// The device is a House Hub.
        case houseHub
        
        /// The device is a House Extension.
        case houseExtension
        
        /// Retrieve an instance of the respective pariticpator delegate for each role.
        ///
        /// - Returns: The respective partiticpator delegate.
        public func participatorDelegate() -> HouseNetworkParticipatorDelegate {
            switch self {
            case .houseHub:
                return HouseNetworkInitiatorParticipator()
            case .houseExtension:
                return HouseNetworkRecieverParticipator()
            }
        }
        
        /// Retrieve an instance of the respective beacon delegate for each role.
        ///
        /// - Returns: The respective beacon delegate.
        public func beaconDelegate() -> MulticastBeaconDelegate {
            switch self {
            case .houseHub:
                return HouseBeaconEmitter()
            case .houseExtension:
                return HouseBeaconListener()
            }
        }
    }
    
    //MARK: - Architecture
    
    /// The architecture that this HouseDevice is running upon, either 64 bit or 32 bit.
    ///
    /// - Important: The value can also be `.unknown`. In this event the architecture is not supported by House and undefined behavour could occur.
    private(set) public var architecture: HouseDevice.Architecture
    
    /// An enumation of different architectures.
    public enum Architecture {
        
        /// A 32 bit architecture.
        case bit32
        
        /// A 64 bit architecture.
        case bit64
        
        /// An unknown byte-size architecture. If this value is ever supplied to `architecture` in an instance of `HouseDevice` undefined behaviour will occur. It is not supported.
        case unknown
    }
    
    //MARK: - Messaging
    
    /// The outbox of the House Device.
    public var messageOutbox: MessageOutboxDelegate = MessageOutbox()
    
    /// The inbox of the House Device.
    public var messageInbox: MessageInboxDelegate = MessageInbox()
    
    //MARK: - Paclages
    
    /// The packages the House Device supports.
    public let packages = PackageRegistry()
    
    //MARK: - Category Delegate
    
    /// The delegates for categories the House Device supports.
    public var categoryDelegate = HouseCategoryDelegates()
    
    /// The main delegate of the House Device.
    public let mainDelegate: HouseProcess
    
}
