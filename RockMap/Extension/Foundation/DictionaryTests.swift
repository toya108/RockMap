//
//  DictionaryTests.swift
//  RockMapTests
//
//  Created by TOUYA KAWANO on 2021/05/29.
//

import XCTest
@testable import RockMap

class DictionaryTests: XCTestCase {

    func makeEmptyExcludedDictionary() throws {
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
