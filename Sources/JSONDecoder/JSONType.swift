//
//  JSONType.swift
//  JSONDecoderPackageDescription
//
//  Created by Alex Soderman on 11/28/17.
//

import Foundation

public enum JSONType: CustomStringConvertible {
    case JSONInt(value: Int)
    case JSONFloat(value: Double)
    case JSONString(value: String)
    case JSONBool(value: Bool)
    case JSONNull()
    case JSONArray(value: [JSONType])
    case JSONObject(value: Dictionary<String, JSONType>)
    
    public var description: String {
        get {
            switch self {
            case .JSONInt(value: let v):
                return "JSONInt: \(v)"
            case .JSONFloat(value: let v):
                return "JSONFloat: \(v)"
            case .JSONString(value: let v):
                return "JSONString: \(v)"
            case .JSONBool(value: let v):
                return "JSONBool: \(v)"
            case .JSONNull:
                return "JSONNull"
            case .JSONArray(value: let v):
                var s: String = ""
                for i in v {
                    s.append("\(i), ")
                }
                return "JSONArray: \(s)"
            case .JSONObject(value: let v):
                return "\(v)"
            }
        }
    }
}

public typealias JSON = Dictionary<String, JSONType>

public func jmap<T>(j: JSONType, key: String, property: inout T) {
    // Maps a property that is passed by reference to the data for the
    // key in JSON
    switch j {
    case .JSONObject(let d):
        if let result = d[key] {
            // data is found
            switch result {
            case .JSONObject(value: let v):
                property = v as! T
            case .JSONArray(value: let v):
                property = v as! T
            case .JSONNull:
                return
            case .JSONBool(value: let v):
                property = v as! T
            case .JSONInt(value: let v):
                property = v as! T
            case .JSONFloat(value: let v):
                property = v as! T
            case .JSONString(value: let v):
                property = v as! T
            }
        } else {
            for (_,v) in d {
                jmap(j: v, key: key, property: &property)
            }
        }
    case .JSONArray(value: let d):
        for e in d {
            jmap(j: e, key: key, property: &property)
        }
    default:
        return
    }
}

