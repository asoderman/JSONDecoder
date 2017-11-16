//
//  JSONParser.swift
//  JSONDecoder
//
//  Created by Alex Soderman on 11/10/17.
//  Copyright © 2017 Alex Soderman. All rights reserved.
//


internal class JSONObject: NSObject {
    
    let key: JSONObject?
    var keys: [JSONObject?]
    var value: Any?
    var values: [JSONObject?]
    
    override var description: String {
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
    
    override init() {
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
                break
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
                continue
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
}

open class JSONParser: NSObject {
    
    let tokens: [JSONToken]
    private var index: Int
    private var inString: Bool
    private var t: JSONToken {
        get {
            return self.tokens[self.index]
        }
    }
    
    override open var description: String {
        get {
            return "JSONParser: parseTree = \(parseTree)"
        }
    }
    
    init(text: String) {
        self.tokens = JSONScanner.scan(input: text)
        self.index = 0
        self.inString = false
        
        super.init()
    }
    
    internal func parseTree() throws -> JSONObject {
        // BUG: if parseTree is accessed twice it attempts to parse twice
        do {
            return try self.parse()
        }
        catch {
            print(error)
            throw error
            }
    }
    
    private func next() {
        self.index += 1
    }
    
    internal func parse() throws -> JSONObject {
        if !(index < tokens.count) {
            throw ParsingError.ExpectedClosingBrace(token: tokens.last!)
        }
            switch (t.type) {
            case .openParen:
               return try parseObject()
            case .colon:
                next() // consume colon
                return try parse()
            case .comma:
                next() // consume comma
                return try parse()
            case .openBracket:
                return try parseArray()
            case .quote:
                next() //consume quote
                let s = JSONString(value: t.value!)
                next() // consume string
                if (t.type != .quote) {
                    throw ParsingError.ExpectedQuote(token: t)
                }
                next() // consume the closing quote token
                return s
            case .alphanum:
                if t.value == "true" || t.value == "false" {
                    let v = t.value!
                    next() // consume the boolean token
                    let result = JSONBool(value: v)
                    return result
                } else {
                    // it is a number
                    let v = t.value!
                    if v.contains(".") {
                        let result = JSONFloat(value: v)
                        next()
                        return result
                    } else {
                        let result = JSONNumber(value: v)
                        next()
                        return result
                    } //consume the alphanumeric token for the number
                }
            default:
                throw ParsingError.UnknownToken(token: t)
            }
    }
    
    private func parseObject() throws -> JSONObject {
        next() // consume the open bracket
        var keys = [JSONObject]()
        var values = [JSONObject]()
        
        while index < tokens.count && t.type != .closeParen {
            let key = try parse()
            let value = try parse()
            
            values.append(value)
            keys.append(key)
        }
        if (self.index < self.tokens.count) {
            next() // consume the inner close brace 
        }
        return JSONObject(key: keys, value: values)
    }
    
    private func parseArray() throws -> JSONObject {
        next() // consume open bracket
        
        var a = [JSONObject]()
        
        while index < tokens.count && t.type != .closeBracket {
            do {
            a.append(try parse())
            } catch {
                throw ParsingError.ExpectedClosingBracket(token: t)
            }
        }
        next() // consume close bracket token
        return JSONArray(input: a)
        
    }
    
    open func flatten() throws -> Dictionary<String, Any> {
        return try self.parseTree().unbox()
    }

}


enum ParsingError: Error {
    
    case ExpectedClosingBrace(token: JSONToken)
    case UnknownToken(token: JSONToken)
    case ExpectedQuote(token: JSONToken)
    case ExpectedClosingBracket(token: JSONToken)
    
    var description: String {
        switch self {
        case .ExpectedClosingBrace(let token):
            return "Parser did not find a closing brace. Instead found: \(token)"
        case .UnknownToken(let token):
            return "Unkown token encountered. \(token)"
        case .ExpectedQuote(let token):
            return "Expected closing quote. Instead found: \(token)"
        case .ExpectedClosingBracket(let token):
            return "Parse did not find a closing bracket. Instead found: \(token)"
            
        }
    }
}
