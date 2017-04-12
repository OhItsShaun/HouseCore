//
//  DudFunctions.swift
//  House
//
//  Created by Shaun Merchant on 16/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import Foundation

/// No implementation of functionalist exists.
///
/// - Important: Termination of application occurs upon call.
///
/// - Parameter message: Message to log.
public func notImplemented(function: String = #function) -> Never {
    fatalError("NOT IMPLEMENTED: " + function)
}
