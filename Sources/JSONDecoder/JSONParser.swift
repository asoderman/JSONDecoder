//
//  JSONParser.swift
//  JSONDecoder
//
//  Created by Alex Soderman on 11/10/17.
//  Copyright © 2017 Alex Soderman. All rights reserved.
//


/* internal class JSONObject: CustomStringConvertible {
    
    let key: JSONObject?
    var keys: [JSONObject?]
    var value: Any?
    var values: [JSONObject?]
    
    var description: String {
        get {
            var s = "{ \n"
            var i = 0
            while i < keys.count && i < values.count {
                s.append("\(keys[i] as Optional) : \(values[i] as Optional) \n")
                i += 1
            }
            s.append("}")
            return s
        }
    }
    
    init() {
        self.key = nil
        self.keys = [JSONObject]()
        self.values = [JSONObject]()
    }
    
    init(key: [JSONObject], value: [JSONObject]) {
        var i = 0
        self.key = nil
        self.keys = [JSONObject]()
        self.values = [JSONObject]()
        while i < key.count && i < value.count {
            self.keys.append(key[i])
            self.values.append(value[i])
            i += 1
        }
    }
    func unbox() -> Dictionary<String, Any> {
        var d = Dictionary<String,Any>()
        var i = 0
        
        while i < self.values.count && i < self.keys.count {
            let k = keys[i] as! JSONString
            let v = values[i]
            switch (v.self) {
            case is JSONString:
                let s = v as! JSONString
                d[k.unbox()] = s.unbox() as String
            case is JSONNumber:
                let s = v as! JSONNumber
                d[k.unbox()] = s.unbox() as Int
            case is JSONFloat:
                let s = v as! JSONFloat
                d[k.unbox()] = s.unbox() as Float
            case is JSONArray:
                let s = v as! JSONArray
                d[k.unbox()] = s.unbox() as [Any]
            case is JSONBool:
                let s = v as! JSONBool
                d[k.unbox()] = s.unbox() as Bool
            case is JSONNull:
                d[k.unbox()] = nil
            default:
                d[k.unbox()] = v!.unbox() as Dictionary<String,Any>
            }
            
            i += 1
        }
        
        return d
    }
}

internal class JSONArray: JSONObject {
    
    let elements: [JSONObject]
    
    override var value: Any? {
        get {
            return self.elements as [JSONObject]
        }
        
        set (input) {
            self.value = input
        }
    }
    
    override var description: String {
        get {
            var s = "[ "
            for e in self.elements {
                s.append("\(e), ")
            }
            s.append(" ]")
            return s
        }
    }
    
    init(input: [JSONObject]) {
        self.elements = input
        super.init()
    }
    
    func unbox() -> [Any] {
        var a = [Any]()
        for x in self.elements {
            switch (x.self) {
            case is JSONString:
                let s = x as! JSONString
                a.append(s.unbox() as String)
            case is JSONNumber:
                let s = x as! JSONNumber
                a.append(s.unbox() as Int)
            case is JSONFloat:
                let s = x as! JSONFloat
                a.append(s.unbox() as Float)
            case is JSONArray:
                let s = x as! JSONArray
                a.append(s.unbox() as [Any])
            case is JSONBool:
                let s = x as! JSONBool
                a.append(s.unbox() as Bool)
            case is JSONNull:
                continue
            default:
                a.append(x.unbox())
            }
        }
        return a
    }
}

internal class JSONString: JSONObject {
    
    let s_value: String
    
    override var description: String {
        get {
            return "JSONString: \(value as! String)"
        }
    }
    
    override var value: Any? {
        get {
            return self.s_value as String
        }
        
        set (input) {
            self.value = s_value
        }
    }
    
    init(value: String) {
        self.s_value = value
        super.init()
    }
    
    func unbox() -> String {
        return self.value as! String
    }
}

internal class JSONBool: JSONObject {
    let b_value: Bool
    
    override var value: Any? {
        get {
            return self.b_value as Bool
        }
        set (input) {
            self.value = input
        }
    }
    
    override var description: String {
        get {
            return "JSONBool: \(value as! Bool)"
        }
    }
    
    func unbox() -> Bool {
        return self.value as! Bool
    }
    
    init(value: String) {
        var v: Bool
        if value == "true" {
            v = true
        } else {
            v = false
        }
        self.b_value = v
        super.init()
    }
}

internal class JSONNull: JSONObject {
    
    override var value: Any? {
        get {
            return nil
        }
        
        set {
            
        }
    }
}

internal class JSONFloat: JSONObject {
    let numberValue: Float
    
    override var value: Any? {
        get {
            return numberValue as Float
        }
        set {
            
        }
    }
    
    init(value: String) {
        self.numberValue = Float(value)!
        super.init()
    }
    
    func unbox() -> Float {
        return self.numberValue
    }
}

internal class JSONNumber: JSONObject {
    
    let numberValue: Int
    override var value: Any? {
        get {
            return self.numberValue as Int
        }
        
        set (input) {
            self.value = input
        }
    }
    
    override var description: String {
        get {
            return "JSONNumber: \(value as! Int)"
        }
    }
    
    init(value: String) {
        self.numberValue = Int(value)!
        super.init()
    }
    
    func unbox() -> Int {
        return self.numberValue
    }
} */

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
