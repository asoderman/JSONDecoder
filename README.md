# Simple JSON Parser 
Written in swift.

### Usage:
Quickstart
```swift
	let j = try! JSONParser(text: JSONTEXT).flatten()

	let name = j["name"] as! String
	let id = j["id"] as! Int
```

Error handling
```swift
	do { 
		let j = try JSONParser(text: BADJSON).flatten()

		let name = j["name"] as! String
		let id = j["id"] as! Int
	} catch {
		// Do something
		}
	}
```