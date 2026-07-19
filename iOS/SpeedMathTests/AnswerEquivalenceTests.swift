import XCTest
@testable import SpeedMath

final class AnswerEquivalenceTests: XCTestCase {
    func testFractionEquivalence() {
        XCTAssertEqual(AnswerValue.reducedFraction(2, 4), AnswerValue.reducedFraction(1, 2))
        XCTAssertEqual(AnswerValue.fraction(num: 1, den: 2), AnswerValue.decimal(0.5))
        XCTAssertEqual(AnswerValue.reducedFraction(12, 4), AnswerValue.integer(3))
    }

    func testDecimalEquivalence() {
        XCTAssertEqual(AnswerValue.decimal(3.0), AnswerValue.integer(3))
        XCTAssertNotEqual(AnswerValue.decimal(0.33), AnswerValue.fraction(num: 1, den: 3))
    }

    func testNegativeFractionSign() {
        let value = AnswerValue.reducedFraction(-3, 4)
        guard case .fraction(let num, let den) = value else {
            return XCTFail("expected fraction case")
        }
        XCTAssertEqual(num, -3)
        XCTAssertEqual(den, 4)
    }

    func testKeypadParse() {
        XCTAssertEqual(AnswerValue.parse(display: "-3"), .integer(-3))
        XCTAssertEqual(AnswerValue.parse(display: "2.5"), .decimal(2.5))
        XCTAssertEqual(AnswerValue.parse(display: "3/4"), .fraction(num: 3, den: 4))
        XCTAssertNil(AnswerValue.parse(display: "banana"))
        XCTAssertNil(AnswerValue.parse(display: ""))
        XCTAssertNil(AnswerValue.parse(display: "3/0"))
    }

    func testDescriptionFormatting() {
        XCTAssertEqual(AnswerValue.decimal(6.1).description, "6.1")
        XCTAssertEqual(AnswerValue.decimal(6.0).description, "6")
        XCTAssertEqual(AnswerValue.fraction(num: 3, den: 4).description, "3/4")
    }
}
