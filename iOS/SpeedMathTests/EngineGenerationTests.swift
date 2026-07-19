import XCTest
@testable import SpeedMath

final class EngineGenerationTests: XCTestCase {
    func testEveryLevelHasAtLeastThreeTemplates() {
        for level in GradeMap.minLevel...GradeMap.maxLevel {
            let count = QuestionEngine.templates(forLevel: level).count
            XCTAssertGreaterThanOrEqual(count, 3, "level \(level) has only \(count) templates")
        }
    }

    func testGeneratedQuestionsAreWellFormed() {
        var rng = SeededRNG(seed: 7)
        for level in stride(from: GradeMap.minLevel, through: GradeMap.maxLevel, by: 3) {
            for _ in 0..<50 {
                let q = QuestionEngine.next(level: level, rng: &rng)
                XCTAssertFalse(q.prompt.isEmpty, "empty prompt at level \(level)")
                XCTAssertFalse(q.steps.isEmpty, "empty steps at level \(level), template \(q.templateID)")
                XCTAssertFalse(q.answer.description.isEmpty)

                if case .fraction(_, let den) = q.answer {
                    XCTAssertGreaterThan(den, 0, "non-positive denominator in \(q.templateID)")
                }
                if case .decimal(let v) = q.answer {
                    let rounded = (v * 100).rounded() / 100
                    XCTAssertEqual(v, rounded, accuracy: 0.0001, "\(q.templateID) produced more than 2 decimal places")
                }
            }
        }
    }
}
