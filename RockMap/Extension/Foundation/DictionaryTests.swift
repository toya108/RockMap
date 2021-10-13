@testable import RockMap
import XCTest

class DictionaryTests: XCTestCase {

    func testsMakeEmptyExcludedDictionary() throws {
        let containsEmptyDictionary = [
            "aaa": "",
            "bbb": 2344,
            "ccc": "aaaaaaa",
            "ddd": true,
            "eee": ""
        ] as [String: Any]

        let result = containsEmptyDictionary.makeEmptyExcludedDictionary()

        XCTAssertNil(result["aaa"])
        XCTAssertNil(result["eee"])
        XCTAssertEqual(result["bbb"] as! Int, containsEmptyDictionary["bbb"] as! Int)
    }
    
}
