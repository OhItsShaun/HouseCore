//
//  Config.swift
//  House
//
//  Created by Shaun Merchant on 09/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// Configuration values that tweak behaviours of the House Device.
public struct Config {
    
    /// The frequency to "heartbeat" network activities, such as beacon emission.
    static let deviceNetworkTimerFrequency: TimeInterval = 10
    
    /// The longitutde of the device.
    static let deviceLatitude = "52.450817"
    
    /// The latitude of the device.
    static let deviceLongitude = "-1.930513"
    
    /// An authorised username to communicate with the Philips Hue Bridge.
    static let philipsHueUsername: String? = "uafGKX2PFFp7yzVbEsncfdSevIsWiB3URrOisjdl"
    
}
