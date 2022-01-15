@testable import Utilities
import XCTest

class NGramGeneratorTests: XCTestCase {

    func testNGramGenerator() {

        XCTAssertEqual(
            NGramGenerator.makeNGram(input: "あいうえお", n: 1),
            ["あ", "い", "う", "え", "お"]
        )

        XCTAssertEqual(
            NGramGenerator.makeNGram(input: "あいうえお", n: 2),
            ["あい", "いう", "うえ", "えお"]
        )

        XCTAssertEqual(
            NGramGenerator.makeNGram(input: "あいうえお", n: 3),
            ["あいう", "いうえ", "うえお"]
        )

        XCTAssertEqual(
            NGramGenerator.makeNGram(input: "あいうえお", n: 5),
            ["あいうえお"]
        )

        XCTAssertEqual(
            NGramGenerator.makeNGram(input: "あいうえお", n: 6),
            []
        )
    }
    
}
