//
//  NetworkMessagingTests.swift
//  House
//
//  Created by Shaun Merchant on 18/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class NetworkMessagingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        HouseNetwork.current().open()
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
