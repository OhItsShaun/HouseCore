//
//  PendingMessageComparableTests.swift
//  House
//
//  Created by Shaun Merchant on 11/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class PendingMessageComparableTests: XCTestCase {

    let priorityMessage = Message(to: 1, priority: .safetyCritical, bundle: ServiceBundle(package: 1, service: 1)!)
    let standardMessage = Message(to: 1, bundle: ServiceBundle(package: 1, service: 1)!)
    
    func testSafetyCriticalPriority() {
        let expiring = PendingMessage(self.standardMessage, expiresAt: Date())
        let priorityMessage = PendingMessage(self.priorityMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(10))
        
        XCTAssert(priorityMessage > expiring)
        XCTAssert(!(priorityMessage < expiring))
        XCTAssert(!(priorityMessage <= expiring))
        XCTAssert(priorityMessage >= expiring)
    }
    
    func testSafetyCriticalPriorityEarlier() {
        let priorityMessage = PendingMessage(self.priorityMessage, expiresAt: Date())
        let expiring = PendingMessage(self.standardMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(10))
        
        XCTAssert(priorityMessage > expiring)
        XCTAssert(!(priorityMessage < expiring))
        XCTAssert(!(priorityMessage <= expiring))
        XCTAssert(priorityMessage >= expiring)
    }
    
    func testSafetyCriticalPriorities() {
        let priorityMessage = PendingMessage(self.priorityMessage, expiresAt: Date())
        let priorityMessage2 = PendingMessage(self.priorityMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(10))
        
        XCTAssert(priorityMessage > priorityMessage2)
        XCTAssert(!(priorityMessage < priorityMessage2))
        XCTAssert(!(priorityMessage <= priorityMessage2))
        XCTAssert(priorityMessage >= priorityMessage2)
    }
    
    func testStandardMessage() {
        let message = PendingMessage(self.standardMessage, expiresAt: Date())
        let message2 = PendingMessage(self.standardMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(10))
        
        XCTAssert(message > message2)
        XCTAssert(!(message < message2))
        XCTAssert(!(message <= message2))
        XCTAssert(message >= message2)
    }
    
    func testTransativity() {
        let message3 = PendingMessage(self.priorityMessage, expiresAt: Date())
        let message = PendingMessage(self.standardMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(10))
        let message2 = PendingMessage(self.standardMessage, expiresAt: Date(), createdAt: Date().addingTimeInterval(20))
        
        XCTAssert(message3 > message)
        XCTAssert(message > message2)
        XCTAssert(message3 > message2)
    }

    static var allTests = [
        ("testSafetyCriticalPriority", testSafetyCriticalPriority),
        ("testSafetyCriticalPriorityEarlier", testSafetyCriticalPriorityEarlier),
        ("testSafetyCriticalPriorities", testSafetyCriticalPriorities),
        ("testStandardMessage", testStandardMessage),
        ("testTransativity", testTransativity)
        ]
}
