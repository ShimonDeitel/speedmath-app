import XCTest
@testable import SpeedMath

@MainActor
final class OnboardingStatsTests: XCTestCase {
    func testCompleteOnboardingSetsLevelAndPlacement() {
        let stats = StatsStore()
        stats.completeOnboarding(placementLevel: 41)
        XCTAssertEqual(stats.snapshot.placementLevel, 41)
        XCTAssertEqual(stats.level, 41)
        XCTAssertTrue(stats.snapshot.hasCompletedOnboarding)
    }

    func testCompleteOnboardingClampsOutOfRangeLevel() {
        let stats = StatsStore()
        stats.completeOnboarding(placementLevel: 0)
        XCTAssertEqual(stats.snapshot.placementLevel, GradeMap.minLevel)

        stats.completeOnboarding(placementLevel: 999_999)
        XCTAssertEqual(stats.snapshot.placementLevel, GradeMap.maxLevel)
    }

    func testFreeLevelCapIsPlacementPlusSpan() {
        let stats = StatsStore()
        stats.completeOnboarding(placementLevel: 41)
        XCTAssertEqual(stats.freeLevelCap, 41 + StatsStore.freeLevelSpan)
    }

    func testFreeLevelCapClampsAtMaxLevel() {
        let stats = StatsStore()
        stats.completeOnboarding(placementLevel: GradeMap.maxLevel)
        XCTAssertEqual(stats.freeLevelCap, GradeMap.maxLevel)
    }
}
