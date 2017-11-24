# Simple JSON Parser 
Written in swift.

### Installation:
Using SPM (in your Package.swift):
```swift
let package = Package(
	name: "NameOfYourProject",
	dependencies: [
		.package(url: "https://github.com/asoderman/JSONDecoder.git", from: "0.1.0")
	]
)
```
then
```
swift package resolve
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