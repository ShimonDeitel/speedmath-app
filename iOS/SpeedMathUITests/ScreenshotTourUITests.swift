import XCTest

/// Walks the golden path and attaches a screenshot at each stop, feeding
/// the ASC screenshot batch scripts. Runs Pro (no ads/paywall in the way)
/// with a fixed seed so the walked questions are reproducible.
final class ScreenshotTourUITests: XCTestCase {
    func testCaptureTour() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest", "-forcePro", "-screenshots"]
        app.launch()

        attach(app, name: "01-Home")

        app.buttons["startButton"].tap()
        XCTAssertTrue(element("answerDisplay", in: app).waitForExistence(timeout: 5))
        attach(app, name: "02-Question-Type")

        let digit = app.buttons["keypadKey_4"]
        if digit.waitForExistence(timeout: 5) { digit.tap() }
        let submit = app.buttons["keypadSubmit"]
        if submit.isEnabled { submit.tap() }
        _ = element("solutionSteps", in: app).waitForExistence(timeout: 5)
        attach(app, name: "03-Solution")

        if app.buttons["nextButton"].waitForExistence(timeout: 5) {
            app.buttons["nextButton"].tap()
        }
        let speedSegment = app.segmentedControls["modePicker"].buttons["Speed"]
        if speedSegment.waitForExistence(timeout: 5) {
            speedSegment.tap()
            attach(app, name: "04-Speed-Mode")
        }

        if app.navigationBars.buttons["Home"].waitForExistence(timeout: 5) {
            app.navigationBars.buttons["Home"].tap()
        }
        app.buttons["profileButton"].tap()
        attach(app, name: "05-Profile")
    }

    /// SwiftUI doesn't reliably surface a container's accessibility
    /// identifier under one predictable XCUIElement type — match any type.
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func attach(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
