//
//  HECP.swift
//  House
//
//  Created by Shaun Merchant on 06/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// Constants defined in the House Network Communication Protocol.
/// If in doubt, refer to the HNCP spec.
struct HNCP {
    
    /// The HNCP we're complying to.
    /// Equivalent to: 0000 0001.
    static let version: UInt8 = 1
    
    /// The intiation signal.
    /// Equivalent to: 0001 0000.
    static let initiation: UInt8 = 16
    
    /// The fall back of "I have no idea whats going on lets terminate".
    /// Equivalent to: 0101 0101.
    static let IHaveNoIdeaWhatYouMean: UInt8 = 85
    
    /// The acknolwedgement signal.
    /// Equivalent to: 0011 0000.
    static let acknowledgement: UInt8 = 48
    
    /// The confirmation signal.
    /// Equivalent to: 0100 0000.
    static let confirmation: UInt8 = 64
    
    /// The signal for rejecting the version of HNCP.
    /// Equivalent to: 0101 0000.
    static let versionRejection: UInt8 = 80
    
    /// The signal for accepting the version of HNCP.
    /// Equivalent to: 1010 0000.
    static let versionAcceptance: UInt8 = 160
    
    /// The signal for no House Identifiers available from houseHub to join it's houseNetwork.
    /// Equivalent to: 0110 0000.
    static let noHI: UInt8 = 96
    
    /// The signal for a complete handshake.
    /// Equivalent to: 0111 0000.
    static let complete: UInt8 = 112
    
    /// The port that Extensions listen for connections on.
    static let extensionListeningPort: Int32 = 40052
    
    /// The port that Hubs listen for connections on.
    static let hubListeningPort: Int32 = 40053
    
    static let multicastPort: UInt16 = 4053
    
    /// The multicast group.
    static let multicastGroup: String = "225.0.0.37"
    
    /// The broadcast message from houseHub.
    static let multicastMessage: String = "houseHub here"
    
    /// The frequency which broadcasts are made.
    static let broadcastFrequency: TimeInterval = 10
    
    /// The set of HNCP error types.
    public enum Error: Swift.Error {
        
        /// A timeout.
        case Timeout
        
        // An unexpected closure of the socket.
        case UnexpectedFailedSocketRead
        
        // A disagreement in HNCP exchanges.
        case FailedHNCP(message: String)
    }
}
