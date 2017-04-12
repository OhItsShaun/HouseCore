//
//  InboxAndPackagesTests.swift
//  House
//
//  Created by Shaun Merchant on 18/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class MessageInboxTests: XCTestCase {

    override func setUp() {
        super.setUp()
        HouseDevice.create(with: HouseDelegate(), using: 1)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testServiceCall() {
        let expectation = XCTestExpectation(description: "Serve fulfillment.")

        let service = Service(1) { data in
            if data.count > 0 {
                XCTFail("Unexpected recieved data.")
            }
            expectation.fulfill()
        }
        
        HouseDevice.current().packages.register(in: 10, service: service)
        
        let serviceBundle = ServiceBundle(package: 10, service: 1)
        let message = Message(to: 1, bundle: serviceBundle!)
        
        HouseDevice.current().messageInbox.recieved(message: message)
        
        XCTWaiter.wait(for: [expectation], timeout: 1)
    }

    func testDeregisteredServiceCall() {
        let service = Service(1) { _ in
            XCTFail("Unexpected call.")
        }
        
        HouseDevice.current().packages.register(in: 10, service: service)
        HouseDevice.current().packages.deregister(in: 10, service: 1)
        
        let serviceBundle = ServiceBundle(package: 10, service: 1)
        let message = Message(to: 1, bundle: serviceBundle!)
        
        HouseDevice.current().messageInbox.recieved(message: message)
        
        RunLoop.current.run(until: Date().addingTimeInterval(1))
    }
    
    
    func testOverwriteRegisteredServiceCall() {
        let expectation = XCTestExpectation(description: "Serve fulfillment.")
        
        let service1 = Service(1) { _ in
            XCTFail("Unexpected call.")
        }
        let service2 = Service(1) { _ in
            expectation.fulfill()
        }
        
        HouseDevice.current().packages.register(in: 10, service: service1)
        HouseDevice.current().packages.register(in: 10, service: service2)
        
        let serviceBundle = ServiceBundle(package: 10, service: 1)
        let message = Message(to: 1, bundle: serviceBundle!)
        
        HouseDevice.current().messageInbox.recieved(message: message)
        
        XCTWaiter.wait(for: [expectation], timeout: 1)
    }
    
    static var allTests = [
        ("testServiceCall", testServiceCall),
        ("testDeregisteredServiceCall", testDeregisteredServiceCall),
        ("testDeregisteredServiceCall", testDeregisteredServiceCall),
        ("testOverwriteRegisteredServiceCall", testOverwriteRegisteredServiceCall),
        ]
    
    private struct HouseDelegate: StartableProcess {
        public func start() {
            
        }
    }
}
