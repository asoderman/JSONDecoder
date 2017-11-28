//
//  JSONType.swift
//  JSONDecoderPackageDescription
//
//  Created by Alex Soderman on 11/28/17.
//

import Foundation

public enum JSONType {
    case JSONInt(Int)
    case JSONFloat(Double)
    case JSONString(String)
    case JSONBool(Bool)
    case JSONNull()
    case JSONArray([JSONType])
    case JSONObject(Dictionary<String, JSONType>)
}

typealias JSON = Dictionary<String, JSONType>
