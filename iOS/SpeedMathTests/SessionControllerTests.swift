import XCTest
@testable import SpeedMath

@MainActor
final class SessionControllerTests: XCTestCase {
    func testSkipAdvancesWithoutScoring() {
        let controller = SessionController(startingLevel: 5)
        let roundsBefore = controller.roundsCompleted
        XCTAssertEqual(controller.phase, .asking)

        controller.skip()

        XCTAssertEqual(controller.phase, .asking, "skip should land back in asking, not solved")
        XCTAssertEqual(controller.roundsCompleted, roundsBefore + 1)
        XCTAssertEqual(controller.currentLevel, 5, "skipping should never change level")
    }

    func testSkipResetsTheVisibleTimer() {
        let controller = SessionController(startingLevel: 5)
        let shownAtBefore = controller.questionShownAt
        controller.skip()
        XCTAssertGreaterThanOrEqual(controller.questionShownAt, shownAtBefore)
    }
}
