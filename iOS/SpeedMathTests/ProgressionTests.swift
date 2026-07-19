import XCTest
@testable import SpeedMath

final class ProgressionTests: XCTestCase {
    func testAdvancesOnFastCorrectStreak() {
        var progression = LevelProgression(level: 10)
        progression.recordAnswer(correct: true, elapsed: 1)
        progression.recordAnswer(correct: true, elapsed: 1)
        XCTAssertEqual(progression.level, 10, "should not advance before 3 fast-correct in a row")
        progression.recordAnswer(correct: true, elapsed: 1)
        XCTAssertEqual(progression.level, 11)
    }

    func testSlowCorrectDoesNotCountTowardStreak() {
        var progression = LevelProgression(level: 10)
        let slow = PaceTarget.seconds(forLevel: 10) + 5
        progression.recordAnswer(correct: true, elapsed: slow)
        progression.recordAnswer(correct: true, elapsed: slow)
        progression.recordAnswer(correct: true, elapsed: slow)
        XCTAssertEqual(progression.level, 10, "slow answers should never trigger a level-up")
    }

    func testRegressesAfterTwoWrong() {
        var progression = LevelProgression(level: 10)
        progression.recordAnswer(correct: false, elapsed: 1)
        XCTAssertEqual(progression.level, 10)
        progression.recordAnswer(correct: false, elapsed: 1)
        XCTAssertEqual(progression.level, 9)
    }

    func testLevelClampsToBounds() {
        var low = LevelProgression(level: 1)
        low.recordAnswer(correct: false, elapsed: 1)
        low.recordAnswer(correct: false, elapsed: 1)
        XCTAssertEqual(low.level, GradeMap.minLevel)

        var high = LevelProgression(level: GradeMap.maxLevel)
        for _ in 0..<3 {
            high.recordAnswer(correct: true, elapsed: 0.1)
        }
        XCTAssertEqual(high.level, GradeMap.maxLevel)
    }

    func testGradeMappingBoundaries() {
        XCTAssertEqual(GradeMap.gradeLabel(for: 1), "Grade 1")
        XCTAssertEqual(GradeMap.gradeLabel(for: 10), "Grade 1")
        XCTAssertEqual(GradeMap.gradeLabel(for: 11), "Grade 2")
        XCTAssertEqual(GradeMap.gradeLabel(for: 120), "Grade 12")
        XCTAssertEqual(GradeMap.gradeLabel(for: 121), "University")
        XCTAssertEqual(GradeMap.gradeLabel(for: 130), "University")
    }

    func testSeededDeterminism() {
        var rngA = SeededRNG(seed: 99)
        var rngB = SeededRNG(seed: 99)
        let qA = (0..<10).map { _ in QuestionEngine.next(level: 25, rng: &rngA) }
        let qB = (0..<10).map { _ in QuestionEngine.next(level: 25, rng: &rngB) }
        XCTAssertEqual(qA, qB, "same seed must produce an identical question sequence")
    }
}
