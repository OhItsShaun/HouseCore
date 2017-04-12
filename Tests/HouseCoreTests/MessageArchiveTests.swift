//
//  MessageTests.swift
//  House
//
//  Created by Shaun Merchant on 11/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class MessageArchiveTests: XCTestCase {
    
    func testSafetyCriticalMessage() {
        let message = randomSafetyCriticalMessage()
        handleMessageArchivingTest(on: message)
    }
    
    func testNormalMessage() {
        let message = randomMessage()
        handleMessageArchivingTest(on: message)
    }
    
    func testCorruptionOfData() {
        let message = Message(to: 1, bundle: ServiceBundle(package: 1, service: 2, data: 3.archive())!)
        var messageData = message.archive()
        messageData.removeLast()

        guard let messageDecoded = Message.unarchive(messageData) else {
            return
        }
        
        XCTFail("Should not have decoded corrupt message: \(messageDecoded)")
    }
    
    static var allTests = [
        ("testSafetyCriticalMessage", testSafetyCriticalMessage),
        ("testNormalMessage", testNormalMessage),
        ("testCorruptionOfData", testCorruptionOfData),
        ]
    
    func handleMessageArchivingTest(on message: Message) {
        let messageData = message.archive()
        
        let messageDecoded = Message.unarchive(messageData)
        XCTAssertNotNil(messageDecoded)
        XCTAssert(message == messageDecoded!)
    }
}
