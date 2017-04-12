//
//  MessageEqualityTests.swift
//  House
//
//  Created by Shaun Merchant on 11/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class MessageEqualityTests: XCTestCase {

    func testSafetyCriticalEquality() {
        let message1 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: Data())!)
        let message2 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: Data())!)
        
        XCTAssert(message1 == message2)
    }
    
    func testSafetyCriticalAndNormalInequality() {
        let message1 = Message(to: 1, priority: .safetyCritical, bundle: ServiceBundle(package: 1, service: 1, data: Data())!)
        let message2 = Message(to: 1, priority: .normal, bundle: ServiceBundle(package: 1, service: 1, data: Data())!)
        
        XCTAssert(message1 != message2)
    }

    func testDataEquality() {
        let message1 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: 1.archive())!)
        let message2 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: 1.archive())!)
        
        XCTAssert(message1 == message2)
    }
    
    func testDataInequality() {
        let message1 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: 1.archive())!)
        let message2 = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1, data: 2.archive())!)
        
        XCTAssert(message1 != message2)
    }
    
    static var allTests = [
        ("testSafetyCriticalEquality", testSafetyCriticalEquality),
        ("testSafetyCriticalAndNormalInequality", testSafetyCriticalAndNormalInequality),
        ("testDataEquality", testDataEquality),
        ("testDataInequality", testDataInequality),
        ]
    
}
