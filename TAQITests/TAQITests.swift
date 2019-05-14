//
//  TAQITests.swift
//  TAQITests
//
//  Created by Samuel Lichlyter on 11/8/18.
//  Copyright © 2018 Samuel Lichlyter. All rights reserved.
//

import XCTest
@testable import TAQI

class TimelineTests: XCTestCase {
    
    var document: Document!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "Location History", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        self.document = Document(fileURL: url)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.document = nil
    }
    
    func testOpenDocument() {
        let promise = expectation(description: "Document Open")
        self.document.open { (success) in
            if success {
                promise.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
