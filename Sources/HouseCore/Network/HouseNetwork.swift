//
//  HouseNetwork.swift
//  House
//
//  Created by Shaun Merchant on 12/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import Foundation
#if os(Linux)
    import Dispatch
#endif

/// A singleton that acts as a link to the House Network.
final public class HouseNetwork {
    
    //MARK: - Static Holders
    
    /// The internal object link to the houseHub.
    /// By default `HouseHub` is lazy evaluated.
    private static var houseNetwork = HouseNetwork()
    
    /// Returns the shared object link to the current houseHub.
    ///
    /// - Note: In order to ensure there is only ever one link to the houseHub we instance a HouseHub object as a private static variable, `_hubLink`, which we never make publicly available. Instead we use `current()` to return a reference to the variable, or instance a HouseHub object if it is not already created.
    ///
    /// - Returns: The shared object link to the current houseHub.
    public static func current() -> HouseNetwork {
        return HouseNetwork.houseNetwork
    }
    
    /// Avoid using.
    public static func destroy() {
        self.houseNetwork = HouseNetwork()
    }
    
    //
    //
    //
    //
    //      Everything above is funky lazy-static evaluation stuff.
    //      Just ignore it and everything will be F.I.N.E.
    //
    //
    //
    //
    
    //MARK: - Delegates
    
    /// The most recent timestamp a connection was made to the House Network.
    public var lastContact: Date = Date.distantPast
    
    /// Pariticipator delegate.
    public var participatorDelegate: HouseNetworkParticipatorDelegate? = nil
    
    /// Listener delegate.
    public var listenerDelegate: PortListenerDelegate? = nil
    
    /// Listener delegate.
    public var beaconDelegate: MulticastBeaconDelegate? = nil
    
    /// Success callback.
    public var responseDelegate: HandshakeSuccessResponseDelegate? = nil
    
    
    //MARK: - Open Network
    
    /// The timer that periodically checks to ensure we keep listening for sockets.
    private var keepAliveTimer: Timer? = nil
    
    /// Dispatch queue.
    private var dispatch = DispatchQueue(label: "houseNetwork", qos: .utility, attributes: .concurrent)
    
    /// Attempt to open a connection to the houseNetwork.
    ///
    /// - important: `open()` is highly asynchronous. It **will** return before it is connected to the houseNetwork.
    public func open(as device: HouseDevice.Role) {
        self.close() // safety 
        
        
        Log.debug("Opening HouseNetwork as \(device)...", in: .network)
        
        let participatorDelegate = device.participatorDelegate()
        let listener = HouseNetworkListener(forwardingConnectionsTo: participatorDelegate.handleNewConnection)
        let beaconDelegate = device.beaconDelegate()
        if let listeningBeacon = beaconDelegate as? MulticastBeaconListenerDelegate {
            listeningBeacon.connectionHandler = participatorDelegate.handleNewConnection
        }
        
        self.listenerDelegate = listener
        self.beaconDelegate = beaconDelegate
        self.participatorDelegate = participatorDelegate
        
        if #available(OSX 10.12, *) {
            self.keepAliveTimer = Timer(timeInterval: Config.deviceNetworkTimerFrequency, repeats: true) { timer in
                Log.debug("Serving network delegates...", in: .network)
                self.dispatch.async {
                    self.beaconDelegate?.perform()
                }
                self.dispatch.async {
                    self.listenerDelegate?.listen()
                }
            }
        } else {
            fatalError("Timer is unavailable on pre-OSX 10.12.")
        }
        self.keepAliveTimer!.fire()
        RunLoop.main.add(self.keepAliveTimer!, forMode: .defaultRunLoopMode)
    }
    
    //MARK: - Close Network
    
    /// Close the connection to the houseNetwork. 
    ///
    /// - important: Don't use this API unless you know what you're doing.
    ///
    public func close() {
        Log.debug("Closing HouseNetwork...", in: .network)
        self.keepAliveTimer?.invalidate()
        self.listenerDelegate?.stop()
        self.participatorDelegate?.close()
    }
    
    deinit {
        self.close()
    }
    
}
