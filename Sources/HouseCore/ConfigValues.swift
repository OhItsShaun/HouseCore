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
    public static var deviceNetworkTimerFrequency: TimeInterval = 10
    
    /// The longitutde of the device.
    public static var deviceLatitude = "52.450817"
    
    /// The latitude of the device.
    public static var deviceLongitude = "-1.930513"
    
    /// An authorised username to communicate with the Philips Hue Bridge.
    public static var philipsHueUsername: String? = "uafGKX2PFFp7yzVbEsncfdSevIsWiB3URrOisjdl"
    
}
