import XCTest

/// Mandatory portfolio test: real tap-outside keyboard dismissal. The answer
/// keypad is custom (no system keyboard), so Settings carries a display-name
/// text field specifically to give this test a real system keyboard target.
final class KeyboardDismissUITests: XCTestCase {
    func testTapOutsideDismissesKeyboard() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest"]
        app.launch()

        let profileButton = app.buttons["profileButton"]
        XCTAssertTrue(profileButton.waitForExistence(timeout: 5))
        profileButton.tap()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "settings button should appear once the profile sheet finishes presenting")
        settingsButton.tap()

        // Settings is a long Form — the "Profile" section (and its display
        // name field) sits below the fold, and SwiftUI Lists only
        // materialize rows once they're actually on screen, so scroll to it
        // rather than expecting it to already exist.
        let field = app.textFields["displayNameField"]
        for _ in 0..<6 where !field.exists {
            app.swipeUp()
        }
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 5), "system keyboard should appear")

        // Tap a neutral point in the form, away from any control and below
        // the navigation bar.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()

        let keyboardGone = NSPredicate(format: "count == 0")
        expectation(for: keyboardGone, evaluatedWith: app.keyboards, handler: nil)
        waitForExpectations(timeout: 5)
    }
}
