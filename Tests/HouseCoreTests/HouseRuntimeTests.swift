//
//  HouseRuntimeTtests.swift
//  Core
//
//  Created by Shaun Merchant on 12/04/2017.
//
//

import XCTest
#if os(Linux)
    import Dispatch
#endif
@testable import HouseCore

class HouseRuntimeTests: XCTestCase {

    let startingExpectation = XCTestExpectation(description: "Starting Process")
    let willStartExpectation = XCTestExpectation(description: "Updating Will Starat Process")
    let updatedExpectation = XCTestExpectation(description: "Updates Did Start Process")
    let dispatch = DispatchQueue(label: "HouseRuntime")
    
    func testStartingDelegate() {
        self.dispatch.async {
            HouseRuntime.run(HouseStartingDelegate(startExpectation: self.startingExpectation), as: .houseExtension)
        }
        let result = XCTWaiter.wait(for: [self.startingExpectation], timeout: 2)
        if result != .completed {
            XCTFail("Failed: \(result)")
        }
    }
    
    func testUpdatingDelegate() {
        self.dispatch.async {
            print("Async running...")
            HouseRuntime.run(HouseUpdatingDelegate(willStart: self.willStartExpectation, updated: self.updatedExpectation), as: .houseExtension)
        }
        let result = XCTWaiter.wait(for: [self.willStartExpectation, self.updatedExpectation], timeout: 3)
        if result != .completed {
            XCTFail("Failed: \(result)")
        }
    }
    
    static var allTests = [
        ("testStartingDelegate", testStartingDelegate),
        ("testUpdatingDelegate", testUpdatingDelegate),
    ]
    
    private struct HouseStartingDelegate: StartableProcess {
        
        let expect: XCTestExpectation
        
        init(startExpectation: XCTestExpectation) {
            self.expect = startExpectation
        }
        
        func start() {
            self.expect.fulfill()
        }
        
    }
    
    private struct HouseUpdatingDelegate: UpdateableProcess {
        
        let updateFrequency: TimeInterval = 1
        
        let willStart: XCTestExpectation
        
        let updated: XCTestExpectation
        
        func updatesWillStart() {
            print("Starting..")
            self.willStart.fulfill()
        }
        
        func update(at time: Date) {
            print("Updating..")
            self.updated.fulfill()
        }
    }
}
