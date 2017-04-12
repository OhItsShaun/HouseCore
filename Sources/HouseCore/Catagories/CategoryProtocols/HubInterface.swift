//
//  HubInterface.swift
//  House
//
//  Created by Shaun Merchant on 20/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// A hub interface represents a device that recieves updates from `House` relating
/// to core data structures, such as connected House Extensions, the Rooms of the House, as 
/// well as registering the ability to control House Extensions on the House Network.
public protocol HubInterfaceDelegate {
    
    func eventDidOccur(of eventType: HubEvent, in domain: HubDomain)

    
}

extension HubInterfaceDelegate {
    
    func room(called name: String, was event: HubEvent) {
        self.eventDidOccur(of: event, in: .room(name: name))
    }
    
    func houseExtension(with identifier: HouseIdentifier, was event: HubEvent) {
        self.eventDidOccur(of: event, in: .houseExtension(identifier: identifier))
    }
    
}

/// The different types of events that can occur in the House Hub.
public enum HubEvent {
    
    /// The entity was removed from `House`.
    case removed
    
    /// The entity was updated or added in `House`.
    case updated
    
}

/// The differen types of domains in the House Hub.
public enum HubDomain {
    
    /// The domain of House Extensions.
    case houseExtension(identifier: HouseIdentifier)
    
    /// The domain of House Rooms.
    case room(name: String)
    
}
