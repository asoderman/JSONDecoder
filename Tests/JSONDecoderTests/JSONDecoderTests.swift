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
    
    func testScanCommaInString() {
        // Ensures the scanner ignores commas in strings
        
        let result = JSONScanner.scan(input: "{\"balance\" : \"$3,000\"}")
        
        XCTAssert(result[6].type == .alphanum)
        
    }
    
    func testScanTokenCharsInString() {
        // Ensures the scanner can scan characters that also happen
        // to be tokens inside of strings
        
        let result = JSONScanner.scan(input: "{\"characters\" : \"[]{}:\" }")
        
        XCTAssert(result[6].type == .alphanum)
    }
    
    func testScanEscapedQuote() {
        let result = JSONScanner.scan(input: "{\"characters\" : \"\\\"\" }")
        XCTAssert(result[6].value == "\"")
    }
    
    func testParse() {
        
        // Test string parsing functionality
        let result = try! JSONParser(text: fullTest).parseTree()
        
        switch result {
        case .JSONObject(value: let d):
            let a = Array(d.keys)
            let b = Array(d.values)
            XCTAssert(a.count == 8 && b.count == 8)
        default:
            XCTFail()
        }
        
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
    
    func testEmptyString() {
        // Ensures the parser can handle empty strings
        let _ = try! JSONParser(text: "{\"name\" : \"\" }").flatten()
    }
    
    func testFlatten() {
        
        let result = try! JSONParser(text: fullTest).flatten()
        
        print(result)
        XCTAssert(result["id"] as! Int == 1)
        XCTAssert((result["numbers"] as! [Any?]).count == 10)
        XCTAssert(result["ratio"] as! Double == 0.5)
    }
    
    func testFlattenObjectInObject() {
        let result = try! JSONParser(text: "{\"object\" : {\"id\" : 1 }}").flatten()
        let o = result["object"] as! Dictionary<String, Any>
        XCTAssert(o["id"] as! Int == 1)
    }
    
    func testFlattenObjectInArray() {
        let result = try! JSONParser(text: "{\"objects\" : [{\"id\" : 1 }]}").flatten()
        let o = result["objects"] as! Array<Any>
        let a = o[0] as! Dictionary<String, Any>
        XCTAssert(a["id"] as! Int == 1)
    }
    
    func testjmap() {
        let result = try! JSONParser(text: numberTest).parse()
        
        var num: Int = 0
        
        jmap(j: result, key: "number", property: &num)
        
        XCTAssert(num == 1234)
    }
}

extension JSONDecoderTests {
    static var allTests : [(String, (JSONDecoderTests) -> () -> Void)] {
    return  [
            ("testScan", testScan),
            ("testScanCommaInString", testScanCommaInString),
            ("testScanTokenCharsInString", testScanTokenCharsInString),
            ("testScanEscapedQuote", testScanEscapedQuote),
            ("testParse", testParse),
            ("testParseFail", testParseFail),
            ("testFlatten", testFlatten),
            ("testEmptyString", testEmptyString)
        ]
    }
}
