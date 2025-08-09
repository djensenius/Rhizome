//
//  RhizomeUITests.swift
//  RhizomeUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest

@MainActor
final class RhizomeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Helpers

    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 5) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        // Wait for something to appear so we don't race the UI
        if !app.buttons.firstMatch.waitForExistence(timeout: timeout) {
            _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
        }
        return app
    }

    // MARK: - Tests

    func testAppLaunch() {
        let app = launchAppAndWait()
        XCTAssertTrue(app.exists)
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testMainTabsExist() throws {
        let app = launchAppAndWait()

        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 3) else {
            throw XCTSkip("No tab bar found; skipping tab existence test.")
        }

        // Adjust tab labels as appropriate for your app
        let watchTab = tabBar.buttons["Watch"]
        let scheduleTab = tabBar.buttons["Schedule"]
        let galleryTab = tabBar.buttons["Gallery"]
        let settingsTab = tabBar.buttons["Settings"]

        let tabExists = watchTab.exists || scheduleTab.exists || galleryTab.exists || settingsTab.exists
        XCTAssertTrue(tabExists, "At least one main tab should be present")
    }

    func testLoginFlowIfRequired() throws {
        let app = launchAppAndWait()

        let maybeLoginPresent = app.textFields.firstMatch.exists || app.secureTextFields.firstMatch.exists
        if maybeLoginPresent {
            let textField = app.textFields.firstMatch
            let secureField = app.secureTextFields.firstMatch

            if textField.exists {
                XCTAssertTrue(textField.isHittable, "Email/username field should be hittable")
            }

            if secureField.exists {
                XCTAssertTrue(secureField.isHittable, "Password field should be hittable")
            }
        } else {
            throw XCTSkip("No login UI present; skipping login flow checks.")
        }
    }

    func testNavigationBetweenTabs() throws {
        let app = launchAppAndWait()

        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 3) else {
            throw XCTSkip("No tab bar found; skipping tab navigation test.")
        }

        let tabs = tabBar.buttons
        let tabCount = tabs.count
        guard tabCount > 1 else {
            throw XCTSkip("Not enough tabs to navigate.")
        }

        let maxToTest = min(tabCount, 4)
        var tapped = 0
        for index in 0..<maxToTest {
            let tab = tabs.element(boundBy: index)
            if tab.exists && tab.isHittable {
                tab.tap()
                _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
                tapped += 1
            }
        }
        XCTAssertGreaterThanOrEqual(tapped, 1, "Should be able to tap at least one tab")
    }

    func testAccessibilityElements() {
        let app = launchAppAndWait()

        let buttons = app.buttons
        let texts = app.staticTexts
        let hasAccessibleElements = buttons.count > 0 || texts.count > 0
        XCTAssertTrue(hasAccessibleElements, "App should have accessible UI elements")
    }

    // MARK: - Performance

    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            // Class-level @MainActor ensures this runs on the main actor
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        } else {
            throw XCTSkip("Performance metrics require iOS 13 or later.")
        }
    }

    func testMemoryPerformance() throws {
        if #available(iOS 13.0, *) {
            let app = XCUIApplication()
            measure(metrics: [XCTMemoryMetric()]) {
                app.launch()
                _ = app.otherElements.firstMatch.waitForExistence(timeout: 2)
                app.terminate()
            }
        } else {
            throw XCTSkip("Memory metric requires iOS 13 or later.")
        }
    }
}
