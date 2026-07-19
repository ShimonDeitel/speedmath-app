import XCTest

/// Free-tier ad placements must never block the golden path: the Start
/// button and keypad stay fully hittable and don't intersect an ad frame.
final class FreeTierLayoutUITests: XCTestCase {
    func testAdSlotsDoNotBlockStartButton() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest"]
        app.launch()

        let start = app.buttons["startButton"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertTrue(start.isHittable, "Start button must stay tappable with ad placeholders on screen")

        let adSlots = app.descendants(matching: .any).matching(identifier: "adSlot")
        XCTAssertGreaterThanOrEqual(adSlots.count, 1, "free tier should show at least one ad placeholder on Home")

        for index in 0..<adSlots.count {
            let ad = adSlots.element(boundBy: index)
            guard ad.exists else { continue }
            XCTAssertFalse(
                ad.frame.intersects(start.frame),
                "ad slot \(index) overlaps the Start button")
        }
    }

    func testKeypadStaysClearOfAds() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest"]
        app.launch()

        app.buttons["startButton"].tap()
        let submit = app.buttons["keypadSubmit"]
        XCTAssertTrue(submit.waitForExistence(timeout: 5))

        let adSlots = app.descendants(matching: .any).matching(identifier: "adSlot")
        for index in 0..<adSlots.count {
            let ad = adSlots.element(boundBy: index)
            guard ad.exists else { continue }
            XCTAssertFalse(
                ad.frame.intersects(submit.frame),
                "ad slot \(index) overlaps the keypad submit button")
        }
    }
}
