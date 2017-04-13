//
//  RecordedValueTests.swift
//  House
//
//  Created by Shaun Merchant on 17/03/2017.
//  Copyright © 2017 Shaun Merchant. All rights reserved.
//

import XCTest
@testable import HouseCore

class RecordedValueTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testComparable() {
        let value1 = RecordedValue(1, recordedAt: Date())
        let value2 = RecordedValue(2, recordedAt: Date().addingTimeInterval(5))
        let value3 = RecordedValue(3, recordedAt: Date().addingTimeInterval(10))
        
        XCTAssert(value1 < value2)
        XCTAssert(value1 <= value2)
        XCTAssert(!(value1 > value2))
        XCTAssert(!(value1 >= value2))
        
        XCTAssert(value2 < value3)
        XCTAssert(value1 < value3)
        
        XCTAssert(value1 == value1)
        XCTAssert(value1 != value2)
    }

}
