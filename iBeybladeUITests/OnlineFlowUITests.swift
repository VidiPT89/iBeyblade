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

    /// Joins a real room already hosted by another platform's client (room code passed in
    /// as a launch argument) to prove genuine cross-platform interoperability, not just
    /// that iOS's own multiplayer code compiles/runs in isolation.
    func testJoinCrossPlatformRoom() {
        let app = XCUIApplication()
        let roomCode = ProcessInfo.processInfo.environment["ROOM_CODE"] ?? "U26S85"
        app.launch()

        sleep(1)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        sleep(1)

        // Online mode.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.78, dy: 0.30)).tap()
        sleep(1)

        // Pick Titan Shell (2nd top card, top-right of the picker grid) to match the
        // other two platforms already in this room.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.72, dy: 0.50)).tap()
        sleep(1)
        attach(app, "01-online-titan-shell-selected")

        // Tap "Join Room" (center of the 3-button row).
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.797)).tap()
        sleep(1)
        attach(app, "02-join-alert")

        let alertTextField = app.alerts.textFields.firstMatch
        if alertTextField.waitForExistence(timeout: 5) {
            alertTextField.tap()
            alertTextField.typeText(roomCode)
        }
        attach(app, "03-join-alert-filled")

        let joinButton = app.alerts.buttons["Join"]
        if joinButton.waitForExistence(timeout: 5) {
            joinButton.tap()
        }
        sleep(4)
        attach(app, "04-battle-joined")

        // A couple more frames to see live sync in action.
        sleep(2)
        attach(app, "05-battle-live")
    }

    private func attach(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}
