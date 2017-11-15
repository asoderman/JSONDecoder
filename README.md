# Simple JSON Parser 
Written in swift.

v 0.0.1

Usage:
```swift
	let j = JSONParser(text: JSONTEXT).flatten()

	let name = j["name"] as! String
	let id = j["id"] as! Int
```
