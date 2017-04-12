//
//  PortListenerTests.swift
//  House
//
//  Created by Shaun Merchant on 25/02/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
import Socket
#if os(Linux)
    import Dispatch
#endif
@testable import HouseCore

class PortListenerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    func testHubPortListener() {
        HouseDevice.create(with: HouseSample(), as: .houseHub)
        
        let dispatch = DispatchQueue(label: "dispatch", qos: .utility, attributes: .concurrent)
        let expectation = XCTestExpectation(description: "Port Listener Expectation")
        let sentData = "hello".archive()
        
        let portListener = HouseNetworkListener() { socket in
            do {
                var data = Data()
                let _ = try socket.read(into: &data)
                
                XCTAssert(data == sentData, "Mismatch data")
                expectation.fulfill()
            }
            catch {
                XCTFail("error: \(error)")
            }
        }
        
        dispatch.async {
            portListener.listen()
        }
        
        dispatch.async {
            do {
                let socket = try Socket.create()
                try socket.connect(to: "localhost", port: HNCP.hubListeningPort)
                try socket.write(from: sentData)
            }
            catch {
                XCTFail("error: \(error)")
            }
        }
        
        XCTWaiter.wait(for: [expectation], timeout: 2)
        
        XCTAssert(portListener.isListening)
        
        portListener.stop()
        
        XCTAssert(!portListener.isListening)
    }
    
    func testExtensionPortListener() {
        HouseDevice.create(with: HouseSample(), as: .houseExtension)
        
        let dispatch = DispatchQueue(label: "dispatch", qos: .utility, attributes: .concurrent)
        let expectation = XCTestExpectation(description: "Port Listener Expectation")
        let sentData = "hello".archive()
        
        let portListener = HouseNetworkListener() { socket in
            do {
                var data = Data()
                let _ = try socket.read(into: &data)
                
                XCTAssert(data == sentData, "Mismatch data")
                expectation.fulfill()
            }
            catch {
                XCTFail("error: \(error)")
            }
        }
        
        dispatch.async {
            portListener.listen()
        }
        
        dispatch.async {
            do {
                let socket = try Socket.create()
                try socket.connect(to: "localhost", port: HNCP.extensionListeningPort)
                try socket.write(from: sentData)
            }
            catch {
                XCTFail("error: \(error)")
            }
        }
        
        XCTWaiter.wait(for: [expectation], timeout: 2)
        
        XCTAssert(portListener.isListening)
        
        portListener.stop()
        
        XCTAssert(!portListener.isListening)
    }
    
    static var allTests = [
        ("testHubPortListener", testHubPortListener),
        ("testExtensionPortListener", testExtensionPortListener),
    ]

}

struct HouseSample: StartableProcess {
    func start() {
        
    }
}
