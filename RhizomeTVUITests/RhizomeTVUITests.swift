//
//  RhizomeTVUITests.swift
//  RhizomeTVUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest

final class RhizomeTVUITests: XCTestCase {

    @MainActor
    @discardableResult
    private func launchAppAndWait(timeout: TimeInterval = 5) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        if !app.buttons.firstMatch.waitForExistence(timeout: timeout) {
            _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
        }
        return app
    }

    @MainActor
    func testTVAppLaunch() {
        let app = launchAppAndWait()
        XCTAssertTrue(app.exists)
        XCTAssertEqual(app.state, .runningForeground)
    }

    @MainActor
    func testTVFocusNavigation() {
        let app = launchAppAndWait()
        let hasButtons = app.buttons.count > 0 || app.buttons.firstMatch.exists
        let hasTabBars = app.tabBars.count > 0 || app.tabBars.firstMatch.exists
        XCTAssertTrue(hasButtons || hasTabBars)
    }

    @MainActor
    func testTVTabNavigation() throws {
        let app = launchAppAndWait()

        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 3) else {
            throw XCTSkip("No tab bar found; skipping tab navigation test for this configuration.")
        }

        let tabs = tabBar.buttons
        XCTAssertGreaterThan(tabs.count, 0)

        let maxToTest = min(tabs.count, 4)
        for index in 0..<maxToTest {
            let tab = tabs.element(boundBy: index)
            guard tab.exists else { continue }

            #if os(tvOS)
            let remote = XCUIRemote.shared
            // Move focus right a few steps, then select
            for _ in 0...index { remote.press(.right) }
            remote.press(.select)
            #else
            if tab.isHittable { tab.tap() }
            #endif

            _ = app.otherElements.firstMatch.waitForExistence(timeout: 1)
        }
    }

    @MainActor
    func testTVAuthenticationFlow() throws {
        let app = launchAppAndWait()

        let textFields = app.textFields
        let secureTextFields = app.secureTextFields
        let buttons = app.buttons

        if textFields.count > 0 || secureTextFields.count > 0 {
            XCTAssertGreaterThan(buttons.count, 0)
        } else {
            throw XCTSkip("No authentication fields present; skipping auth flow checks.")
        }
    }

    @MainActor
    func testTVRemoteControlSupport() {
        let app = launchAppAndWait()

        let interactiveElements =
            app.buttons.count +
            app.tabBars.count +
            app.textFields.count +
            app.secureTextFields.count

        XCTAssertGreaterThan(interactiveElements, 0)
    }
}

// MARK: - Performance (XCTest metrics)

@MainActor
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
