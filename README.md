# Simple JSON Parser 
Written in swift.

### Installation:
Using SPM (in your Package.swift):
```swift
let package = Package(
	name: "NameOfYourProject",
	dependencies: [
		.Package(url: "https://github.com/asoderman/JSONDecoder.git", majorVersion: 0, minorVersion: 1)
	]
)
```

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