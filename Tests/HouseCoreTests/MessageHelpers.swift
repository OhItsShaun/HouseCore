//
//  MessageHelpers.swift
//  House
//
//  Created by Shaun Merchant on 22/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation
import Archivable
import Random 
@testable import HouseCore

public func randomMessage(for identifier: HouseIdentifier = HouseIdentifier(Random.generate())) -> Message {
    let bundle = ServiceBundle(package: 1, service: 1, data: Data())!
    
    return Message(to: identifier, bundle: bundle)
}

public func randomSafetyCriticalMessage(for identifier: HouseIdentifier = HouseIdentifier(Random.generate())) -> Message {
    let bundle = ServiceBundle(package: 1, service: 1, data: Data())!
    
    return Message(to: identifier, priority: .safetyCritical, bundle: bundle)
}

public func createMessage(for identifier: HouseIdentifier, data: Archivable) -> Message {
    let bundle = ServiceBundle(package: 1, service: 1, data: data.archive())!
    
    return Message(to: identifier, priority: .safetyCritical, bundle: bundle)
    
}
