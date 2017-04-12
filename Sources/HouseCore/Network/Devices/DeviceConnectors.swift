//
//  HouseDeviceConnectors.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Socket 
#if os(Linux)
    import Dispatch
#endif

/// A collection of connected house devices.
public struct HouseDeviceConnectors {
    
    /// The connected house devices.
    fileprivate var knownDevices = [HouseIdentifier: HouseDeviceConnector]()
    
    /// Workers that are servicing extensions.
    fileprivate var deviceWorkers = [HouseIdentifier: HouseDeviceWorker]()
    
    /// A queue for device workers to execute upon.
    fileprivate let deviceQueue = DispatchQueue(label: "houseNetwork.concurrentDeviceRead", qos: .utility, attributes: .concurrent)
    
    /// A lock for modifying connected devices.
    fileprivate let lock = DispatchQueue(label: "houseNetwork.KnownDevicesLock", qos: .utility)
    
}

// MARK: - Insert & Retrieve Connectors
public extension HouseDeviceConnectors {
    
    /// Check if a device exists by House Identifier.
    ///
    /// - Parameter houseIdentifier: The house identifier to check.
    /// - Returns: Whether the device exists.
    public func contains(_ houseIdentifier: HouseIdentifier) -> Bool {
        return self.knownDevices.keys.contains(houseIdentifier)
    }
    
    /// Retrieve the connector for a House Device.
    ///
    /// - Parameter houseIdentifier: The identifier of the device to retrieve the connector for.
    /// - Returns: The connector for the device if it is known, otherwise nil.
    fileprivate func retrieveConnector(using houseIdentifier: HouseIdentifier) -> HouseDeviceConnector? {
        return self.knownDevices[houseIdentifier]
    }
    
    /// Insert a device connector.
    ///
    /// - Parameters:
    ///   - connector: The device connector to insert.
    ///   - stop: If `connector` is overwriting a previously existing connector, stop will stop an existing running worker for the previous connector.
    fileprivate mutating func insert(_ connector: HouseDeviceConnector, stoppingWorker stop: Bool = true) {
        self.lock.sync {
            self.knownDevices[connector.houseIdentifier] = connector
            
            if stop {
                self.retrieveWorker(using: connector.houseIdentifier)?.stop()
            }
        }
    }
    
    /// Update an existing connectors information, or create a new connector if one does not already exist, and create a worker to serive the socket.
    ///
    /// - Parameters:
    ///   - ipAddress: The address of the House Device.
    ///   - activeSocket: The active socket of the House Device to spawn a worker for.
    ///   - houseIdentifier: The identifier of the House Device.
    public mutating func updateConnector(address ipAddress: String, activeSocket: Socket? = nil, for houseIdentifier: HouseIdentifier) {
        var deviceConnector: HouseDeviceConnector
        
        // If we have a connector...
        if let connector = self.retrieveConnector(using: houseIdentifier) {
            // If our IP is newer than the existing one..
            if connector.ipAddress != ipAddress {
                // Replace that connector with our newer connector
                deviceConnector = HouseDeviceConnector(for: houseIdentifier, atAddress: ipAddress)
                self.insert(deviceConnector)
            }
            // Otherwise our connector is not as "fresh"
            else {
                deviceConnector = connector
                // However, if our worker isn't still running - we have have a socket for it!
                if let worker = self.retrieveWorker(using: houseIdentifier), worker.running {
                    Log.debug("IP same and worker active for: \(houseIdentifier)", in: .connectedDevices)
                    activeSocket?.close()
                    return
                }
            }
        }
        else {
            deviceConnector = HouseDeviceConnector(for: houseIdentifier, atAddress: ipAddress)
            self.insert(deviceConnector)
        }
        
        // Update workers
        if let socket = activeSocket {
            if let worker = self.deviceWorkers[houseIdentifier] {
                worker.stop()
                self.deviceWorkers.removeValue(forKey: houseIdentifier)
            }
            let worker = HouseDeviceWorker(for: houseIdentifier, usingSocket: socket, onDispatch: self.deviceQueue)
            worker.start()
            self.deviceWorkers[houseIdentifier] = worker
        }
    }
}

// MARK: - Create & Retrieve Workers
public extension HouseDeviceConnectors {
    
    /// Find or create an active worker to a House Device.
    ///
    /// - Parameter identifier: The identifier of the device to find, or create, an active worker for.
    /// - Returns: An active worker for the House Device, nil if a connection couldn't be established or the device is not known.
    public mutating func houseWorker(for identifier: HouseIdentifier) -> HouseDeviceWorker? {
        // If we already have a worker..
        if let existingWorker = self.retrieveWorker(using: identifier) {
            if existingWorker.running {
                return existingWorker
            }
            else {
                existingWorker.stop()
            }
        }
        
        // Otherwise guard we have the device
        guard let device = self.retrieveConnector(using: identifier) else {
            return nil
        }
        
        // And try to create that worker
        return self.createWorker(for: device)
    }
    
    /// Retrieve an existing worker for a House Device.
    ///
    /// - Parameter houseIdentifier: The identifier of the device to find the worker for.
    /// - Returns: The worker for the device, nil if a worker does not exist.
    ///
    /// - Important: The worker may not be active. Check the worker is active before sending data.
    func retrieveWorker(using houseIdentifier: HouseIdentifier) -> HouseDeviceWorker? {
        return self.deviceWorkers[houseIdentifier]
    }
    
    /// Create a worker for a House Device.
    ///
    /// - Parameter connector: The connector to create a worker for.
    /// - Returns: The worker for the device if a connection could be established, nil otherwise.
    public mutating func createWorker(for deviceConnector: HouseDeviceConnector) -> HouseDeviceWorker? {
        guard let socket = deviceConnector.newConnection() else {
            return nil
        }
        
        let newWorker = HouseDeviceWorker(for: deviceConnector.houseIdentifier, usingSocket: socket, onDispatch: self.deviceQueue)
        
        self.deviceWorkers[deviceConnector.houseIdentifier] = newWorker
        
        return newWorker
    }
}

// MARK: - Stop Devices
public extension HouseDeviceConnectors {
    
    /// Stop all workers.
    public mutating func stopAll() {
        self.lock.sync {
            for (_, worker) in self.deviceWorkers {
                worker.stop()
            }
            self.deviceWorkers = [:]
        }
    }
    
}

// MARK: - Forward Messages
public extension HouseDeviceConnectors {
    
    /// Forward a message to its indended recipient.
    ///
    /// - Parameter message: The message to forward.
    /// - Returns: Whether the message was sent successfully or not.
    public mutating func forward(message: Message) -> Bool {
        return self.lock.sync {
            defer {
                if HouseNetwork.current().lastContact.addingTimeInterval(300) < Date() {
                    if HouseNetwork.current().beaconDelegate == nil {
                        Log.warning("Not heard from House in substantial time. Re-opening UDP beacon.", in: .network)
                        HouseNetwork.current().beaconDelegate = HouseDevice.current().role.beaconDelegate()
                    }
                    else {
                        Log.debug("Not heard from House in substantial time. UDP beacon already open.", in: .network)
                    }
                }
            }
            guard let worker = self.houseWorker(for: message.recipient) else {
                Log.fatal("Unable to deliver message: \(message) to: \(message.recipient). No device connector found.", in: .networkMessages)
                return false
            }
            
            if !worker.write(message: message) {
                Log.fatal("Unable to deliver message: \(message) to: \(message.recipient). Could not write to socket.", in: .networkMessages)
                return false
            }
            return true
        }
    }
    
}

// MARK: - Sequence
extension HouseDeviceConnectors: Sequence {
    
    public func makeIterator() -> DictionaryIterator<HouseIdentifier, HouseDeviceConnector> {
        return self.knownDevices.makeIterator()
    }
    
}
