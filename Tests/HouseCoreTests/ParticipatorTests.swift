//
//  ParticipatorTests.swift
//  House
//
//  Created by Shaun Merchant on 19/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
import Socket
#if os(Linux)
    import Dispatch
#endif
@testable import HouseCore

class ParticipatorTests: XCTestCase {
    
    var houseInitiator: HouseNetworkInitiatorParticipator! = nil
    
    var houseReciever: HouseNetworkRecieverParticipator! = nil
    
    var dispatch = DispatchQueue(label: "dispatch", qos: .userInitiated, attributes: .concurrent)
    
    override func setUp() {
        super.setUp()
        
        HouseDevice.create(with: HouseDelegate())
        houseInitiator = HouseNetworkInitiatorParticipator()
        houseReciever = HouseNetworkRecieverParticipator()
    }
    
    override func tearDown() {
        houseInitiator.close()
        houseReciever.close()
        
        super.tearDown()
    }

    func testHandshake() {
        let hubExpectation = XCTestExpectation(description: "Hub Expectation")
        let extExpectation = XCTestExpectation(description: "Extension Expectation")
        
        do {
            let socket1 = try Socket.create()
            try socket1.listen(on: Int(HNCP.hubListeningPort))
            
            self.dispatch.async {
                do {
                    let incoming = try socket1.acceptClientConnection()
                    let response = self.houseInitiator.performHandshake(with: incoming)
                    if response.status == .failed {
                        XCTFail("Handshake failed.")
                    }
                    
                    hubExpectation.fulfill()
                }
                catch {
                    XCTFail("\(error)")
                }
            }
            
            let socket2 = try Socket.create()
            self.dispatch.async {
                do {
                    try socket2.connect(to: "localhost", port: HNCP.hubListeningPort)
                    let response = self.houseReciever.performHandshake(with: socket2)
                    if response.status == .failed {
                        XCTFail("Handshake failed.")
                    }
                    
                    XCTAssert(response.houseIdentifier == HouseIdentifier.hub, "Exepcted Hub, recieved: \(response)")
                    
                    extExpectation.fulfill()
                }
                catch {
                    XCTFail("\(error)")
                }
            }
        }
        catch {
            XCTFail("\(error)")
        }
        
        XCTWaiter.wait(for: [hubExpectation, extExpectation], timeout: 3)
    }
    
    static var allTests = [
        ("testHandshake", testHandshake),
        ]

}
