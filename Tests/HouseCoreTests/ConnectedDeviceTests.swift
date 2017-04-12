//
//  ConnectedDeviceTests.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class ConnectedDeviceTests: XCTestCase {

    func testInequality() {
        let device1 = HouseDeviceConnector(for: 1, atAddress: "192.0.0.1")
        let device2 = HouseDeviceConnector(for: 2, atAddress: "192.0.0.1")
        
        XCTAssert(device1 != device2)
    }
    
    func testEquality() {
        let device1 = HouseDeviceConnector(for: 1, atAddress: "192.0.0.1")
        let device2 = HouseDeviceConnector(for: 1, atAddress: "192.0.0.1")
        
        XCTAssert(device1 == device2)
    }
    
    func testEqualityDifferentIPs() {
        let device1 = HouseDeviceConnector(for: 1, atAddress: "192.0.0.1")
        let device2 = HouseDeviceConnector(for: 1, atAddress: "192.0.0.2")
        
        XCTAssert(device1 == device2)
    }
    
    static var allTests = [
        ("testInequality", testInequality),
        ("testEquality", testEquality),
        ("testEqualityDifferentIPs", testEqualityDifferentIPs),
        ]

}
