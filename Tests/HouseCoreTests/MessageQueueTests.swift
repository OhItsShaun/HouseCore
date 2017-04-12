//
//  MessageOutboxTests.swift
//  House
//
//  Created by Shaun Merchant on 10/12/2016.
//  Copyright © 2016 Shaun Merchant. All rights reserved.
//

import XCTest
import Random
@testable import HouseCore

class MessageOutboxTests: XCTestCase, MessageOutboxResponderDelegate {
    
    var queue: MessageOutboxDelegate! = nil

    override func setUp() {
        super.setUp()
        
        queue = MessageOutbox()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testRetrievingSafetyCritical() {
        let criticalMessage = randomSafetyCriticalMessage()
        queue.add(message: criticalMessage)
        
        if let message = queue.pop(for: criticalMessage.recipient)?.message {
            XCTAssert(message == criticalMessage)
        }
        else {
            XCTFail("MessageOutbox returned nil when expected Message")
        }
    }
    
    func testPopOfSafetyCriticalTilNil() {
        let criticalMessage = randomSafetyCriticalMessage()
        queue.add(message: criticalMessage)
        
        let _ = queue.pop(for: criticalMessage.recipient)
        let shouldBeNil = queue.pop(for: criticalMessage.recipient)
        
        if let _ = shouldBeNil {
            XCTFail("MessageOutbox returned message that sould be nil")
        }
    }

    func testSafetyCriticalExpirary() {
        let criticalMessage = randomSafetyCriticalMessage()
        queue.add(message: criticalMessage, expiresAt: Date().addingTimeInterval(0.5))
        
        sleep(1)
        
        if let _ = queue.pop(for: criticalMessage.recipient) {
            XCTFail("MessageOutbox return message that should have expired")
        }
    }
    
    func testSafetyCriticalShouldntExpire() {
        let criticalMessage = randomSafetyCriticalMessage()
        queue.add(message: criticalMessage, expiresAt: Date().addingTimeInterval(2))
        
        sleep(1)
        
        if nil == queue.pop(for: criticalMessage.recipient) {
            XCTFail("MessageOutbox return nil when should have returned message")
        }
    }
    
    func testPriorityOfSafetyCriticalOverNormal() {
        let criticalMessage = randomSafetyCriticalMessage()
        let normalMessage = randomMessage()
        
        queue.add(message: normalMessage)
        queue.add(message: criticalMessage)
        
        let shouldBeSafetyCritical = queue.pop(for: criticalMessage.recipient)
        let shouldBeNormal = queue.pop(for: normalMessage.recipient)
        let shouldBeNil = queue.pop(for: normalMessage.recipient)
        let shouldBeNilToo = queue.pop(for: criticalMessage.recipient)
        
        if let message = shouldBeSafetyCritical?.message {
            XCTAssert(message == criticalMessage)
        }
        else {
            XCTFail()
        }

        if let message = shouldBeNormal?.message {
            XCTAssert(message == normalMessage)
        }
        else {
            XCTFail()
        }
        
        if let _ = shouldBeNil {
            XCTFail()
        }
        if let _ = shouldBeNilToo {
            XCTFail()
        }
    }
    
    func testMessageRetirvalAfterExpirary() {
        let criticalMessage = randomSafetyCriticalMessage()
        let normalMessage = randomMessage()
        
        queue.add(message: criticalMessage, expiresAt: Date().addingTimeInterval(0.5))
        queue.add(message: criticalMessage, expiresAt: Date().addingTimeInterval(0.6))
        queue.add(message: normalMessage)
        
        sleep(1)
        
        let shouldBeNormal = queue.pop(for: normalMessage.recipient)
        
        if let message = shouldBeNormal?.message {
            XCTAssert(message == normalMessage)
        }
        else {
            XCTFail()
        }
    }
    
    func testMultiThreadingMessageSafety() {
        let pool = DispatchQueue(label: "dispatch", attributes: .concurrent)
        
        for _ in 0..<50 {
            pool.async {
                self.queue.add(message: randomSafetyCriticalMessage(for: 1))
            }
        }
        for _ in 0..<200 {
            pool.async {
                self.queue.add(message: randomMessage(for: 1))
            }
        }
        for _ in 0..<10 {
            pool.async {
                self.queue.add(message: randomSafetyCriticalMessage(for: 1))
            }
        }
        for _ in 0..<200 {
            pool.async {
                self.queue.add(message: randomMessage(for: 1))
            }
        }
        
        RunLoop.main.run(until: Date().addingTimeInterval(2))
        
        for _ in 0..<460 {
            let message = queue.pop(for: 1)
            if message == nil {
                XCTFail("Correupted queue.")
            }
        }
        
    }
    
    func testSequentialityOfBacklog() {
        self.queue.outboxResponderDelegate = self
        let pool = DispatchQueue(label: "dispatch")
        
        for i in 0..<100 {
            pool.async {
                self.queue.add(message: createMessage(for: 1, data: i))
            }
        }
        
        
        RunLoop.main.run(until: Date().addingTimeInterval(3))
        
        var messagesStored = 0
        var createdTime: Date? = nil
        
        while let backlog = self.queue.pop(for: 1) {
            let message = backlog.message
            
            if let id = Int.unarchive(message.bundle.data) {
                XCTAssert(id == messagesStored)
            }
            else {
                XCTFail("Could not unarchive ID.")
            }
            
            if let earlierTime = createdTime {
                XCTAssert(backlog.createdTime > earlierTime)
                createdTime = backlog.createdTime
            }
            else {
                createdTime = backlog.createdTime
            }
            
            messagesStored += 1
        }
        
        XCTAssert(messagesStored == 100)
        
    }
    
    static var allTests = [
        ("testRetrievingSafetyCritical", testRetrievingSafetyCritical),
        ("testPopOfSafetyCriticalTilNil", testPopOfSafetyCriticalTilNil),
        ("testSafetyCriticalExpirary", testSafetyCriticalExpirary),
        ("testSafetyCriticalShouldntExpire", testSafetyCriticalShouldntExpire),
        ("testPriorityOfSafetyCriticalOverNormal", testPriorityOfSafetyCriticalOverNormal),
        ("testMessageRetirvalAfterExpirary", testMessageRetirvalAfterExpirary),
        ("testMultiThreadingMessageSafety", testMultiThreadingMessageSafety),
        ("testSequentialityOfBacklog", testSequentialityOfBacklog),
        ]
    
    func didRecieveNewMessage(for recipient: HouseIdentifier) {
        var backlogged = [PendingMessage]()
        for _ in 0..<Random.generate(max: 10) {
            if let backlog = self.queue.pop(for: 1) {
                backlogged += [backlog]
            }
            else {
                break
            }
        }
        
        for backlog in backlogged {
            self.queue.backlog(message: backlog)
        }
    }
}


