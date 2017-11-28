# Simple JSON Parser 
Written in swift. [![Build Status](https://travis-ci.org/asoderman/JSONDecoder.svg?branch=master)](https://travis-ci.org/asoderman/JSONDecoder)

### Installation:
Using SPM (in your Package.swift):
```swift
let package = Package(
	name: "NameOfYourProject",
	dependencies: [
		.package(url: "https://github.com/asoderman/JSONDecoder.git", from: "0.1.1")
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

### To work on this library:
1. Fork this repo on github.
2. Create a local copy of your repo.
3. ```swift package generate-xcodeproj ```
4. Submit pull requests.
