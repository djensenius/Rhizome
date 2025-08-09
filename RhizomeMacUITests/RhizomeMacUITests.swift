//
//  RhizomeMacUITests.swift
//  RhizomeMacUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest

final class RhizomeMacUITests: XCTestCase {

    // Keep setUp nonisolated (matches XCTest's signature) and avoid touching UI APIs here.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // Launch helper runs on the main actor so we can safely access XCUI elements.
    @MainActor
    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 10) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTesting"]
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launch()

        // Wait for a window or a commonly-present element to appear
        let windowAppeared = app.windows.firstMatch.waitForExistence(timeout: timeout)
        if !windowAppeared {
            _ = app.buttons.firstMatch.waitForExistence(timeout: 2)
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2)
        }
        return app
    }

    // MARK: Tests

    @MainActor
    func testAppLaunch() {
        let app = launchAppAndWait()
        XCTAssertEqual(app.state, .runningForeground, "App should be running in foreground after launch.")
        XCTAssertTrue(app.windows.firstMatch.exists, "Main window should exist after launch.")
    }

    @MainActor
    func testGridViewExists() {
        let app = launchAppAndWait()

        let visibleUI =
            app.collectionViews.firstMatch.exists ||
            app.scrollViews.firstMatch.exists ||
            app.images.firstMatch.exists ||
            app.staticTexts.firstMatch.exists

        XCTAssertTrue(visibleUI, "App should present visible UI (collection/scroll view, images, or labels).")
    }

    @MainActor
    func testSidebarNavigation() {
        let app = launchAppAndWait()

        let hasSidebar =
            app.splitGroups.firstMatch.waitForExistence(timeout: 2) ||
            app.outlines.firstMatch.waitForExistence(timeout: 2)

        let hasButtons =
            app.buttons.firstMatch.waitForExistence(timeout: 2) ||
            app.toolbars.buttons.firstMatch.waitForExistence(timeout: 2)

        XCTAssertTrue(hasSidebar || hasButtons,
                      "Mac app should expose navigation elements (sidebar, outline, or toolbar/buttons)."
        )
    }

    @MainActor
    func testControlsPresence() {
        let app = launchAppAndWait()

        let hasControls =
            app.steppers.firstMatch.exists ||
            app.segmentedControls.firstMatch.exists ||
            app.sliders.firstMatch.exists ||
            app.buttons.firstMatch.exists

        XCTAssertTrue(hasControls, "Mac app should expose control elements (stepper/segmented control/slider/button).")
    }

    @MainActor
    func testWindowPresence() {
        let app = launchAppAndWait()
        XCTAssertTrue(app.windows.firstMatch.exists, "Main window should exist.")
        // Keep resize interactions out to avoid CI flakiness
    }
}

final class RhizomeMacUIPerfTests: XCTestCase {

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchArguments += ["-uiTesting"]
                app.launchEnvironment["UI_TESTING"] = "1"
                app.launch()
            }
        } else {
            throw XCTSkip("Performance metrics require macOS 10.15 or later.")
        }
    }

    @MainActor
    func testMacMemoryPerformance() throws {
        if #available(macOS 10.15, *) {
            measure(metrics: [XCTMemoryMetric()]) {
                let app = XCUIApplication()
                app.launchArguments += ["-uiTesting"]
                app.launchEnvironment["UI_TESTING"] = "1"
                app.launch()
                _ = app.windows.firstMatch.waitForExistence(timeout: 3)
                app.terminate()
            }
        } else {
            throw XCTSkip("Memory metrics require macOS 10.15 or later.")
        }
    }
}
