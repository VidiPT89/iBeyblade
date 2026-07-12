import XCTest

final class OnlineFlowUITests: XCTestCase {
    func testCapture() {
        let app = XCUIApplication()
        app.launch()

        // Dismiss splash (full-screen tap target).
        sleep(1)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)

        attach(app, "01-menu-default")

        // Tap "Online" mode pill (top-right of the 3-button mode row).
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.78, dy: 0.30)).tap()
        sleep(1)
        attach(app, "02-menu-online")

        // Tap "Create Room" (left of the 3-button row where Start normally sits).
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.22, dy: 0.797)).tap()
        sleep(3)
        attach(app, "03-waiting-for-opponent")

        // Tap Cancel (wherever it lands — same area, panel is roughly the same rect).
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62)).tap()
        sleep(1)
        attach(app, "04-back-to-idle-lobby")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
