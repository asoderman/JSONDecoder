//
//  JSONScanner.swift
//  JSONDecoder
//
//  Created by Alex Soderman on 11/10/17.
//  Copyright © 2017 Alex Soderman. All rights reserved.
//

class JSONScanner: NSObject {
    
    static func scan(input: String) -> [JSONToken] {
        
        var tokens = [JSONToken]()
        var buffer: String = ""
        var scanningString = false
        
        func commitString() {
            if buffer != "" {
                tokens.append(JSONToken(type: .alphanum, value: buffer))
                buffer = ""
            }
        }
        
        for c in input {
            switch (c) {
            case "{":
                tokens.append(JSONToken(type: .openParen))
            case ":":
                tokens.append(JSONToken(type: .colon))
            case "}":
                commitString()
                tokens.append(JSONToken(type: .closeParen))
            case "\"":
                commitString()
                scanningString = !scanningString
                tokens.append(JSONToken(type: .quote))
            case "[":
                tokens.append(JSONToken(type: .openBracket))
            case "]":
                commitString()
                tokens.append(JSONToken(type: .closeBracket))
            case ",":
                commitString()
                tokens.append(JSONToken(type: .comma))
            default:
                if scanningString {
                    buffer.append(c)
                } else if c == "\n" || c == "\t"{
                    continue
                } else if c == " " {
                    if buffer != "" {
                        commitString()
                    }
                    continue
                } else {
                    buffer.append(c)
                }
            }
        }
        return tokens
    }

}
