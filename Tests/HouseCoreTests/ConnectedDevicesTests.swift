//
//  ConnectedDevicesTests.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class HouseDeviceConnectorsTests: XCTestCase {

    var connectedDevices: HouseDeviceConnectors! = nil
    
    override func setUp() {
        self.connectedDevices = HouseDeviceConnectors()
    }
    
    func testContainsUniqueIdentifier() {
        self.connectedDevices.updateConnector(address: "192.0.0.1", for: 1)
        
        guard self.connectedDevices.contains(1) else {
            XCTFail()
            return
        }
    }
    
    static var allTests = [
        ("testContainsUniqueIdentifier", testContainsUniqueIdentifier),
    ]

}
