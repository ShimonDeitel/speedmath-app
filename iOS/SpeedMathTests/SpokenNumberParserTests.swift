import XCTest
@testable import SpeedMath

final class SpokenNumberParserTests: XCTestCase {
    func testDirectDigitsPassThrough() {
        XCTAssertEqual(SpokenNumberParser.parse("42"), .integer(42))
        XCTAssertEqual(SpokenNumberParser.parse("3/4"), .fraction(num: 3, den: 4))
        XCTAssertEqual(SpokenNumberParser.parse("2.5"), .decimal(2.5))
    }

    func testWordNumbers() {
        XCTAssertEqual(SpokenNumberParser.parse("forty two"), .integer(42))
        XCTAssertEqual(SpokenNumberParser.parse("minus three"), .integer(-3))
        XCTAssertEqual(SpokenNumberParser.parse("negative seven"), .integer(-7))
        XCTAssertEqual(SpokenNumberParser.parse("one hundred twelve"), .integer(112))
        XCTAssertEqual(SpokenNumberParser.parse("two thousand five"), .integer(2005))
    }

    func testWordFractions() {
        XCTAssertEqual(SpokenNumberParser.parse("three quarters"), .fraction(num: 3, den: 4))
        XCTAssertEqual(SpokenNumberParser.parse("three fourths"), .fraction(num: 3, den: 4))
        XCTAssertEqual(SpokenNumberParser.parse("a half"), .fraction(num: 1, den: 2))
        XCTAssertEqual(SpokenNumberParser.parse("one over eight"), .fraction(num: 1, den: 8))
        XCTAssertEqual(SpokenNumberParser.parse("negative seven over eight"), .reducedFraction(-7, 8))
    }

    func testWordDecimals() {
        XCTAssertEqual(SpokenNumberParser.parse("two point five"), .decimal(2.5))
        XCTAssertEqual(SpokenNumberParser.parse("zero point three three"), .decimal(0.33))
    }

    func testFillerStripping() {
        XCTAssertEqual(SpokenNumberParser.parse("the answer is forty two"), .integer(42))
        XCTAssertEqual(SpokenNumberParser.parse("um twelve"), .integer(12))
    }

    func testRejectsGarbage() {
        XCTAssertNil(SpokenNumberParser.parse("banana"))
        XCTAssertNil(SpokenNumberParser.parse(""))
        XCTAssertNil(SpokenNumberParser.parse("hello there"))
    }
}
