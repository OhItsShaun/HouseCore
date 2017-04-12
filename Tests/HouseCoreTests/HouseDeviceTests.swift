//
//  HouseDeviceTests.swift
//  House
//
//  Created by Shaun Merchant on 14/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore


/// Tests the platform stability & minimum requirements of house.
/// If any of these tests fail undefined behaviour could occur and house **should not** be executed on this architecture.
class HouseDeviceTests: XCTestCase {

    func testArchitecture() {
        HouseDevice.create(with: HouseDelegate())
        XCTAssert(HouseDevice.current().architecture != .unknown, "Unsupported architecture for House. Undefined behaviour could occur.")
    }
    
    static var allTests = [
        ("testArchitecture", testArchitecture),
        ]
    
}

struct HouseDelegate: StartableProcess {
    
    func start() {
        
    }
}
