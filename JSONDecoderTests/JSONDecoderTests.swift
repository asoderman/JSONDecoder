//
//  JSONDecoderTests.swift
//  JSONDecoderTests
//
//  Created by Alex Soderman on 11/10/17.
//  Copyright © 2017 Alex Soderman. All rights reserved.
//

import XCTest
@testable import JSONDecoder


class JSONDecoderTests: XCTestCase {
    
    let numberTest = "{\"number\" : 1234}"
    let stringTest = "{\"name\" : \"john\"}"
    let boolTest = "{\"auth\" : false, \"logged_in\" : true}"
    let arrayTest = "{\"numbers\" : [1,2,3,4,5] }"
    let objectTest = "{\"json\" : {\"data\" : [1,2]} }"
    let noCloseBraceTest = "{\"json\" : 12"
    let noCloseQuote = "{\"json\" : \"a string}"
    let noCloseBracket = "{\"json\" : [ 1, 2, 3 }"
    
    let fullTest = """
    {
        \"userId\": 1,
        \"id\": 1,
        \"title\": \"sunt aut facere repellat provident occaecati excepturi optio reprehenderit\",
        \"body\": \"quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto\",
        \"numbers\" : [1,2,3,4,5,6,7,8,9,10],
        \"ratio\" : 0.5,
        \"things\" : { \"more_numbers\" : [[1,2], [3,4], [5,6]] },
        \"more_things\" : [1,2]
        
    }
"""
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            let _ = try! JSONParser(text: fullTest).flatten()
        }
    }
    
    func testScan() {
        let result = JSONScanner.scan(input: fullTest)
        
        XCTAssert(result[0].type == .openParen)
        XCTAssert(result[1].type == .quote)
        XCTAssert(result.last!.type == .closeParen)
        XCTAssert(result[result.endIndex - 1].type == .closeParen)
    }
    
    func testParse() {
        
        // Test string parsing functionality
        let result = try! JSONParser(text: stringTest).parseTree()
        
        XCTAssert(result.keys.count == 1 && result.values.count == 1)
        
        // Test number parsing functionality
        
        let numberResult = try! JSONParser(text: numberTest).parseTree()
        
        XCTAssert(numberResult.values[0]?.value! as! Int == 1234)
        
        // Test boolean parsing functionality
        let bool_result = try! JSONParser(text: boolTest).parseTree()
        
        XCTAssert(bool_result.keys.count == 2 && bool_result.values.count == 2)
        
        // Test array parsing functionality
        let testArrays = arrayTest
        let arrayResults = try! JSONParser(text: testArrays).parseTree()
        let a = arrayResults.values[0] as! JSONArray
        XCTAssert(a.elements.count == 5)
        
        // full test
        let fullResult = try! JSONParser(text: fullTest).parseTree()
        XCTAssert(fullResult.keys.count == 8)
        
    }
    
    func testParseFail() {
        // Tests that the parser can fail
        // The closures will only be called if the code succesfully runs
        // with improper JSON.
        
        if let _ = try? JSONParser(text: noCloseBraceTest).parseTree() {
            XCTFail("No error thrown for JSON without closing brace")
            return
        }
        if let _ = try? JSONParser(text: noCloseQuote).parseTree() {
            XCTFail("No error thrown for JSON without closing quote")
            return
        }
        
        if let _ = try? JSONParser(text: noCloseBracket).parseTree() {
            XCTFail("No error thrown for JSON Array without closing bracket.")
            return
        }
        
        
    }
    
    func testFlatten() {
        
        let result = try! JSONParser(text: fullTest).flatten()
        
        XCTAssert(result["id"] as! Int == 1)
        XCTAssert((result["numbers"] as! [Any?]).count == 10)
        XCTAssert(result["ratio"] as! Float == 0.5)
    }
    
}
