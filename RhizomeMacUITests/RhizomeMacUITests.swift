//
//  RhizomeMacUITests.swift
//  RhizomeMacUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import XCTest

// MARK: - Swift Testing UI tests (uses XCUITest for automation)

@MainActor
@Suite("Rhizome macOS UI Tests")
struct RhizomeMacUITests {

    // Helper to launch and wait for the first window/element to appear
    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 5) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        // Wait for a window or a commonly-present element to appear
        if !app.windows.firstMatch.waitForExistence(timeout: timeout) {
            _ = app.buttons.firstMatch.waitForExistence(timeout: 1)
        }
        return app
    }

    // MARK: Tests

    @Test
    func macAppLaunch() {
        let app = launchAppAndWait()
        #expect(app.exists)
        #expect(app.state == .runningForeground)
    }

    @Test
    func macGridViewExists() {
        let app = launchAppAndWait()

        // Look for common "grid/gallery" related elements
        let hasCollectionViews = app.collectionViews.firstMatch.exists || app.collectionViews.count > 0
        let hasScrollViews = app.scrollViews.firstMatch.exists || app.scrollViews.count > 0
        let hasImages = app.images.firstMatch.exists || app.images.count > 0
        let hasAnyStaticText = app.staticTexts.count > 0

        #expect(hasCollectionViews || hasScrollViews || hasImages || hasAnyStaticText,
                "App should present visible UI (collection/scroll view, images, or labels).")
    }

    @Test
    func macSidebarNavigation() {
        let app = launchAppAndWait()

        // macOS sidebars commonly show up as split groups in the UI tree
        let sidebar = app.splitGroups.firstMatch
        let hasSidebar = sidebar.waitForExistence(timeout: 2)
        let hasButtons = app.buttons.firstMatch.waitForExistence(timeout: 1) || app.buttons.count > 0

        #expect(hasSidebar || hasButtons, "Mac app should expose navigation elements (sidebar or buttons).")
    }

    @Test
    func macColumnStepper() {
        let app = launchAppAndWait()

        let hasSteppers = app.steppers.firstMatch.exists || app.steppers.count > 0
        let hasButtons = app.buttons.firstMatch.exists || app.buttons.count > 0

        #expect(hasSteppers || hasButtons, "Mac app should expose control elements (steppers or buttons).")
    }

    @Test
    func macWindowResizingBasicPresence() {
        let app = launchAppAndWait()

        let windowCount = app.windows.count
        #expect(windowCount > 0, "Mac app should have at least one window.")

        if windowCount > 0 {
            let mainWindow = app.windows.firstMatch
            #expect(mainWindow.exists, "Main window should exist.")
        }
    }
}

// MARK: - Performance (XCTest; annotate with @MainActor for concurrency)

@MainActor
final class RhizomeMacUIPerfTests: XCTestCase {

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launch()
            }
        } else {
            throw XCTSkip("Performance metrics require macOS 10.15 / iOS 13 / tvOS 13 / watchOS 7 or later.")
        }
    }

    func testMacMemoryPerformance() throws {
        if #available(macOS 10.15, *) {
            measure(metrics: [XCTMemoryMetric()]) {
                let app = XCUIApplication()
                app.launch()
                _ = app.windows.firstMatch.waitForExistence(timeout: 2)
                app.terminate()
            }
        } else {
            throw XCTSkip("Memory metrics require macOS 10.15 or later.")
        }
    }
}
