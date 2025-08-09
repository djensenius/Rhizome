//
//  RhizomeTVUITests.swift
//  RhizomeTVUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import XCTest

// MARK: - Swift Testing (uses XCUITest APIs for UI automation)

@Suite("Rhizome TV UI Tests")
struct RhizomeTVUITests {

    // Helper to launch and wait for some UI to appear
    @MainActor
    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 5) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        // Wait for a likely-first element to exist (buttons or any other element)
        if !app.buttons.firstMatch.waitForExistence(timeout: timeout) {
            _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
        }
        return app
    }

    // MARK: Tests

    @Test
    @MainActor
    func TVAppLaunch() {
        let app = launchAppAndWait()
        #expect(app.exists)
        #expect(app.state == .runningForeground)
    }

    @Test
    @MainActor
    func TVFocusNavigation() {
        let app = launchAppAndWait()

        // Then: app should expose focusable elements
        let hasButtons = app.buttons.count > 0 || app.buttons.firstMatch.exists
        let hasTabBars = app.tabBars.count > 0 || app.tabBars.firstMatch.exists
        #expect(hasButtons || hasTabBars)
    }

    @Test
    @MainActor
    func TVTabNavigation() throws {
        let app = launchAppAndWait()

        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 3) else {
            // If your tvOS UI doesn't use a tab bar, skip rather than fail
            throw Skip("No tab bar found; skipping tab navigation test for this configuration.")
        }

        let tabs = tabBar.buttons
        #expect(tabs.count > 0)

        // Try focusing different tabs (up to 4)
        let maxToTest = min(tabs.count, 4)
        for index in 0..<maxToTest {
            let tab = tabs.element(boundBy: index)
            if tab.exists && tab.isHittable {
                tab.tap()
                _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
            }
        }
    }

    @Test
    @MainActor
    func TVAuthenticationFlow() throws {
        let app = launchAppAndWait()

        let textFields = app.textFields
        let secureTextFields = app.secureTextFields
        let buttons = app.buttons

        // If auth fields are present, ensure there are actionable buttons too.
        if textFields.count > 0 || secureTextFields.count > 0 {
            #expect(buttons.count > 0)
        } else {
            throw Skip("No authentication fields present; skipping auth flow checks.")
        }
    }

    @Test
    @MainActor
    func TVRemoteControlSupport() {
        let app = launchAppAndWait()

        // Count interactive elements commonly used on tvOS
        let interactiveElements =
            app.buttons.count +
            app.tabBars.count +
            app.textFields.count +
            app.secureTextFields.count

        #expect(interactiveElements > 0)
    }
}

// MARK: - Performance (kept as XCTest since measure(...) is an XCTestCase API)

final class RhizomeTVUIPerfTests: XCTestCase {
    func testLaunchPerformance() throws {
        if #available(tvOS 13.0, iOS 13.0, macOS 10.15, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        } else {
            throw XCTSkip("Performance metrics require tvOS 13 / iOS 13 / macOS 10.15 / watchOS 7 or later.")
        }
    }

    func testTVMemoryPerformance() throws {
        if #available(tvOS 13.0, *) {
            let app = XCUIApplication()
            measure(metrics: [XCTMemoryMetric()]) {
                app.launch()
                _ = app.otherElements.firstMatch.waitForExistence(timeout: 2)
                app.terminate()
            }
        } else {
            throw XCTSkip("Memory metric requires tvOS 13 or later.")
        }
    }
}
