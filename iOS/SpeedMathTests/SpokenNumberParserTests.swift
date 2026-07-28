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

    func testHomophoneSubstitution() {
        XCTAssertEqual(SpokenNumberParser.parse("to"), .integer(2))
        XCTAssertEqual(SpokenNumberParser.parse("for"), .integer(4))
        XCTAssertEqual(SpokenNumberParser.parse("ate"), .integer(8))
        XCTAssertEqual(SpokenNumberParser.parse("won"), .integer(1))
        XCTAssertEqual(SpokenNumberParser.parse("free"), .integer(3))
        XCTAssertEqual(SpokenNumberParser.parse("twenty won"), .integer(21))
    }

    func testFillerSuffixesStripped() {
        XCTAssertEqual(SpokenNumberParser.parse("forty two i think"), .integer(42))
        XCTAssertEqual(SpokenNumberParser.parse("seven maybe"), .integer(7))
        XCTAssertEqual(SpokenNumberParser.parse("nine probably"), .integer(9))
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

    func testSelfCorrectionUsesLastValue() {
        XCTAssertEqual(SpokenNumberParser.parse("seven no eight"), .integer(8))
        XCTAssertEqual(SpokenNumberParser.parse("seven, no, eight"), .integer(8))
        XCTAssertEqual(SpokenNumberParser.parse("forty two wait actually forty three"), .integer(43))
        XCTAssertEqual(SpokenNumberParser.parse("three quarters no scratch that one half"), .fraction(num: 1, den: 2))
        XCTAssertEqual(SpokenNumberParser.parse("twelve i mean thirteen"), .integer(13))
    }
}
