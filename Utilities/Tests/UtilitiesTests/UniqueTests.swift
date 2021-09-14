@testable import Utilities
import XCTest

class UniqueTests: XCTestCase {
    func testUnique() {
        XCTAssertEqual([1, 1, 1, 1].unique, [1])

        XCTAssertEqual([1, 2, 1, 1].unique, [1, 2])

        XCTAssertEqual([1, 2, 3, 1].unique, [1, 2, 3])

        XCTAssertEqual([1, 2, 3, 4].unique, [1, 2, 3, 4])
    }
}
