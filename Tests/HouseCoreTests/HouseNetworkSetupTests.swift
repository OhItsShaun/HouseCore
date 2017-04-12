//
//  NetworkRescheduleTests.swift
//  House
//
//  Created by Shaun Merchant on 04/01/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class NetworkSetupTests: XCTestCase {

    override func setUp() {
        HouseNetwork.current().open(as: .houseHub)
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
    }
    
    override func tearDown() {
        HouseNetwork.current().close()
        HouseNetwork.destroy()
    }
    
//    func testListening() {
//        XCTAssert(HouseNetwork.current().state == .listening)
//    }
//
//    func testConnectingToOpenPort() {
//        do {
//            let socket = try Socket.create(family: .inet6)
//            try socket.connect(to: "localhost", port: HNCP.port)
//            
//            XCTAssert(socket.isConnected)
//            XCTAssert(HouseNetwork.current().state == .listening, "Expected .listening, recieved: \(HouseNetwork.current().state)")
//        }
//        catch let error {
//            XCTFail("Recieved Error in catch: \(error)")
//        }
//    }
//    
//    func testDroppedConnectionToOpenPort() {
//        do {
//            let socket = try Socket.create(family: .inet6)
//            try socket.connect(to: "localhost", port: HNCP.port)
//            
//            socket.close()
//            
//            XCTAssert(!socket.isConnected)
//            XCTAssert(HouseNetwork.current().state == .listening)
//        }
//        catch let error {
//            XCTFail("Recieved Error in catch: \(error)")
//        }
//    }
//    
//    func testDroppedConnectionAndReconnectingToOpenPort() {
//        do {
//            var socket = try Socket.create(family: .inet6)
//            try socket.connect(to: "localhost", port: HNCP.port)
//            
//            socket.close()
//            
//            XCTAssert(!socket.isConnected)
//            
//            socket = try Socket.create(family: .inet6)
//            try socket.connect(to: "localhost", port: HNCP.port)
//            
//            XCTAssert(socket.isConnected)
//            XCTAssert(HouseNetwork.current().state == .listening)
//        }
//        catch let error {
//            XCTFail("Recieved Error in catch: \(error)")
//        }
//        
//    }
//    
//    func testHandshakeAsHouse() {
//        do {
//            let socket = try Socket.create(family: .inet6)
//            try socket.connect(to: "localhost", port: HNCP.port)
//
//            /// 1. We send HNCP.initiation
//            try socket.write(from: HNCP.initiation.archive())
//            
//            /// 2. We recieve HNCP.acknolwedgement and HNCP.version
//            var data = Data(capacity: 2)
//            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
//                XCTFail("Time out waiting for ack + ver")
//                return
//            }
//            
//            _ = try socket.read(into: &data)
//            let ack = try UInt8.unarchive(data.remove(to: 1))
//            let version = try UInt8.unarchive(data)
//            
//            guard ack == HNCP.acknowledgement else {
//                XCTFail("Did not recieve acknowledgement.")
//                return
//            }
//            
//            guard version == HNCP.version else {
//                XCTFail("Did not recieve version.")
//                return
//            }
//   
//            /// 3. We send HNCP.versionAcceptance
//            try socket.write(from: HNCP.versionAcceptance.archive())
//
//            /// 4. We recieve unique identifier
//            data = Data(capacity: MemoryLayout<UInt64>.size)
//            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
//                XCTFail("Time out waiting for device identifier")
//                return
//            }
//            
//            _ = try socket.read(into: &data)
//            _ = try UInt64.unarchive(data)
//            
//            /// 5. We send House Identifier
//            try socket.write(from: (10 as HouseIdentifier).archive())
//            
//            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
//            
//            XCTAssert(10 == HouseDevice.current().identifier)
//            
//            /// 6. We recieve confirmation.
//            data = Data(capacity: 1)
//            guard let _ = try Socket.wait(for: socket, timeout: 5000) else {
//                XCTFail("Time out waiting for conf")
//                return
//            }
//            
//            _ = try socket.read(into: &data)
//            let conf = try UInt8.unarchive(try data.remove(to: 1))
//            
//            guard conf == HNCP.complete else {
//                XCTFail("Did not recieve complete.")
//                return
//            }
//            
//            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
//            
//            XCTAssert(HouseNetwork.current().state == .connected)
//        }
//        catch let error {
//            XCTFail("Recieved Error in catch: \(error)")
//        }
//    }
}
