//
//  RhizomeVisionUITests.swift
//  RhizomeVisionUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest

@MainActor
final class RhizomeVisionUITests: XCTestCase {

    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 10) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        if !app.buttons.firstMatch.waitForExistence(timeout: timeout) {
            _ = app.otherElements.firstMatch.waitForExistence(timeout: 2)
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2)
        }
        return app
    }

    // MARK: - Tests

    func testAppLaunch() {
        let app = launchAppAndWait()
        XCTAssertTrue(app.exists)
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testMainUIExists() {
        let app = launchAppAndWait()

        let hasUI =
            app.buttons.firstMatch.exists ||
            app.staticTexts.firstMatch.exists ||
            app.otherElements.firstMatch.exists

        XCTAssertTrue(hasUI, "visionOS app should present visible UI elements")
    }

    func testLoginFlowIfRequired() throws {
        let app = launchAppAndWait()

        let maybeLoginPresent =
            app.textFields.firstMatch.exists ||
            app.secureTextFields.firstMatch.exists

        if maybeLoginPresent {
            let secureField = app.secureTextFields.firstMatch

            if secureField.exists {
                XCTAssertTrue(secureField.isHittable, "Password field should be hittable")
            }
        } else {
            throw XCTSkip("No login UI present; skipping login flow checks.")
        }
    }

    func testNavigationElements() {
        let app = launchAppAndWait()

        let hasNavigation =
            app.tabBars.firstMatch.exists ||
            app.buttons.count > 0 ||
            app.navigationBars.firstMatch.exists

        XCTAssertTrue(hasNavigation, "visionOS app should have navigation elements")
    }

    func testAccessibilityElements() {
        let app = launchAppAndWait()

        let buttons = app.buttons
        let texts = app.staticTexts
        let hasAccessibleElements = buttons.count > 0 || texts.count > 0
        XCTAssertTrue(hasAccessibleElements, "App should have accessible UI elements")
    }
}

// MARK: - Performance

@MainActor
final class RhizomeVisionUIPerfTests: XCTestCase {

    func testLaunchPerformance() throws {
        if #available(visionOS 1.0, iOS 13.0, macOS 10.15, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        } else {
            throw XCTSkip("Performance metrics not available.")
        }
    }

    func testMemoryPerformance() throws {
        if #available(visionOS 1.0, iOS 13.0, macOS 10.15, *) {
            let app = XCUIApplication()
            measure(metrics: [XCTMemoryMetric()]) {
                app.launch()
                _ = app.otherElements.firstMatch.waitForExistence(timeout: 2)
                app.terminate()
            }
        } else {
            throw XCTSkip("Memory metrics not available.")
        }
    }
}
