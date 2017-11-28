//
//  JSONParser.swift
//  JSONDecoder
//
//  Created by Alex Soderman on 11/10/17.
//  Copyright © 2017 Alex Soderman. All rights reserved.
//



open class JSONParser: CustomStringConvertible {
    
    let tokens: [JSONToken]
    private var index: Int
    private var inString: Bool
    private var t: JSONToken {
        get {
            return self.tokens[self.index]
        }
    }
    
    open var description: String {
        get {
            return "JSONParser: parseTree = \(parseTree)"
        }
    }
    
    public init(text: String) {
        self.tokens = JSONScanner.scan(input: text)
        self.index = 0
        self.inString = false
    }
    
    internal func parseTree() throws -> JSONType {
        // BUG: if parseTree is accessed twice it attempts to parse twice
        do {
            return try self.parse()
        }
        catch {
            print(error)
            throw error
            }
    }
    
    private func next() throws {
        self.index += 1
        //print("Token: \(index)/\(tokens.count)")
        if index > tokens.count {
            throw ParsingError.ExpectedClosingBrace()
        }
    }
    
    internal func parse() throws -> JSONType {
        if !(index < tokens.count) {
            throw ParsingError.ExpectedClosingBrace()
        }
            switch (t.type) {
            case .openParen:
               return try parseObject()
            case .colon:
                try next() // consume colon
                return try parse()
            case .comma:
                try next() // consume comma
                return try parse()
            case .openBracket:
                return try parseArray()
            case .quote:
                try next() //consume quote
                let s: JSONType
                if  index < tokens.count && t.value != nil {
                    s = JSONType.JSONString(value: t.value!)
                    try next() // consume string
                } else  {
                    s = JSONType.JSONString(value: "")
                }
                if (index < tokens.count && t.type != .quote) {
                    throw ParsingError.ExpectedQuote(token: t)
                }
                try next() // consume the closing quote token
                return s
            case .alphanum:
                if t.value == "true" || t.value == "false" {
                    try next() // consume the boolean token
                    let result: JSONType
                    switch t.value! {
                    case "true":
                       result = JSONType.JSONBool(value: true)
                    case "false":
                        result = JSONType.JSONBool(value: false)
                    default:
                        throw ParsingError.ExpectedBool
                    }
                    return result
                } else if t.value == "null" {
                    let result = JSONType.JSONNull()
                    try next() // consume the null token
                    return result
                } else {
                    // it is a number
                    let v = t.value!
                    if v.contains(".") {
                        let result = JSONType.JSONFloat(value: Double(v)!)
                        try next()
                        return result
                    } else {
                        let result = JSONType.JSONInt(value: Int(v)!)
                        try next()
                        return result
                    } //consume the alphanumeric token for the number
                }
            default:
                throw ParsingError.UnknownToken(token: t)
            }
    }
    
    private func parseObject() throws -> JSONType {
        try next() // consume the open bracket
        var d = Dictionary<String, JSONType>()
        
        while index < tokens.count && t.type != .closeParen {
            let key = try parse()
            let value = try parse()
            switch key {
            case .JSONString(value: let v):
                d[v] = value
            default:
                throw ParsingError.ExpectedIdentifier
            }
            
        }
        if (self.index < self.tokens.count) {
            try next() // consume the inner close brace
        }
        
        return JSONType.JSONObject(value: d)
    }
    
    private func parseArray() throws -> JSONType {
        try next() // consume open bracket
        
        var a = [JSONType]()
        
        while index < tokens.count && t.type != .closeBracket {
            do {
            a.append(try parse())
            } catch {
                throw ParsingError.ExpectedClosingBracket(token: t)
            }
        }
        try next() // consume close bracket token
        return JSONType.JSONArray(value: a)
        
    }
    
    open func flatten() throws -> Dictionary<String, Any?> {
        
        func flatten_helper(j: JSONType) -> Any? {
            switch j {
            case .JSONObject(let v):
                var d = Dictionary<String, Any?>()
                for (key, value) in v {
                    d[key] = flatten_helper(j: value)
                }
                return d
            case .JSONArray(value: let v):
                var a = [Any]()
                for e in v {
                    a.append(flatten_helper(j: e))
                }
                return a
            case .JSONBool(value: let v):
                return v
            case .JSONInt(value: let v):
                return v
            case .JSONString(value: let v):
                return v
            case .JSONFloat(value: let v):
                return v
            case .JSONNull:
                return nil
            }
        }
        
        do {
            let v = try self.parseTree()
            let result = flatten_helper(j: v) as! Dictionary<String, Any?>
        
            return result
        } catch {
            throw ParsingError.NoTopLevelObject
        }
    }
}


enum ParsingError: Error {
    
    case ExpectedClosingBrace()
    case UnknownToken(token: JSONToken)
    case ExpectedQuote(token: JSONToken)
    case ExpectedClosingBracket(token: JSONToken)
    case ExpectedIdentifier
    case ExpectedBool
    case NoTopLevelObject
    
    var description: String {
        switch self {
        case .ExpectedClosingBrace():
            return "Parser did not find a closing brace."
        case .UnknownToken(let token):
            return "Unkown token encountered. \(token)"
        case .ExpectedQuote(let token):
            return "Expected closing quote. Instead found: \(token)"
        case .ExpectedClosingBracket(let token):
            return "Parse did not find a closing bracket. Instead found: \(token)"
        case .ExpectedIdentifier:
            return "Parse Expected an identfier for the object property. Instead found non-string type."
        case .ExpectedBool:
            return "Parse expected a bool but instead received a string that was not true or false."
        case .NoTopLevelObject:
            return ""
        }
    }
}
