import XCTest

/// Mandatory portfolio test: real tap-outside keyboard dismissal. The answer
/// keypad is custom (no system keyboard), so Settings carries a display-name
/// text field specifically to give this test a real system keyboard target.
final class KeyboardDismissUITests: XCTestCase {
    func testTapOutsideDismissesKeyboard() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest"]
        app.launch()

        app.buttons["profileButton"].tap()
        app.buttons["settingsButton"].tap()

        let field = app.textFields["displayNameField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 5), "system keyboard should appear")

        // Tap a neutral point in the form, away from any control.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)).tap()

        let keyboardGone = NSPredicate(format: "count == 0")
        expectation(for: keyboardGone, evaluatedWith: app.keyboards, handler: nil)
        waitForExpectations(timeout: 5)
    }
}
