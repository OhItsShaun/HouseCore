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

    func testPortListener() {
        let dispatch = DispatchQueue(label: "dispatch", qos: .utility, attributes: .concurrent)
        let expectation = XCTestExpectation(description: "Port Listener Expectation")
        let sentData = "hello".archive()
        
        let portListener = HouseNetworkListener(forwardingConnectionsTo: { socket in
            do {
                var data = Data()
                let _ = try socket.read(into: &data)
                
                XCTAssert(data == sentData, "Mismatch data")
                expectation.fulfill()
            }
            catch {
                XCTFail("error: \(error)")
            }
        })
        
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
    
    static var allTests = [
        ("testPortListener", testPortListener),
    ]

}
