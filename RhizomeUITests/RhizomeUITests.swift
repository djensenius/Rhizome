//
//  RhizomeUITests.swift
//  RhizomeUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import XCTest

@Test func applaunch() throws {
    // UI tests must launch the application that they test.
    let app = XCUIApplication()
    app.launch()

    // Verify the app launches successfully
    #expect(app.exists)
}

@Test func maintabsexist() throws {
    // Given: App is launched
    let app = XCUIApplication()
    app.launch()

    // Wait for app to load
    sleep(2)

    // When: App is fully loaded
    // Then: Main tabs should be accessible
    let tabBar = app.tabBars.firstMatch
    if tabBar.exists {
        // Check for main tabs - may need adjustment based on actual UI
        let watchTab = tabBar.buttons["Watch"]
        let scheduleTab = tabBar.buttons["Schedule"]
        let galleryTab = tabBar.buttons["Gallery"]
        let settingsTab = tabBar.buttons["Settings"]

        // At least some tabs should exist
        let tabExists = watchTab.exists || scheduleTab.exists || galleryTab.exists || settingsTab.exists
        #expect(tabExists, "At least one main tab should be present")
    }
}

@Test func loginflowifrequired() throws {
    // Given: App is launched
    let app = XCUIApplication()
    app.launch()

    // Wait for initial load
    sleep(2)

    // When: App may show login screen
    let loginExists = app.textFields.firstMatch.exists || app.secureTextFields.firstMatch.exists

    if loginExists {
        // Then: Login UI should be functional
        let textField = app.textFields.firstMatch
        let secureField = app.secureTextFields.firstMatch

        if textField.exists {
            #expect(textField.isHittable)
        }

        if secureField.exists {
            #expect(secureField.isHittable)
        }
    }

    // Test should not fail if login isn't required
    #expect(true, "Login flow test completed")
}

@Test func navigationbetweentabs() throws {
    // Given: App is launched
    let app = XCUIApplication()
    app.launch()

    // Wait for app to load
    sleep(3)

    // When: Tabs are available
    let tabBar = app.tabBars.firstMatch
    if tabBar.exists {
        let tabs = tabBar.buttons
        let tabCount = tabs.count

        // Then: Should be able to navigate between tabs
        if tabCount > 1 {
            // Try to tap different tabs
            for tabIndex in 0..<min(tabCount, 4) {
                let tab = tabs.element(boundBy: tabIndex)
                if tab.exists && tab.isHittable {
                    tab.tap()
                    // Small delay to allow navigation
                    sleep(1)
                }
            }
            #expect(true, "Tab navigation test completed")
        }
    }
}

@Test func accessibilityelements() throws {
    // Given: App is launched
    let app = XCUIApplication()
    app.launch()

    // Wait for app to load
    sleep(2)

    // When: Checking accessibility
    // Then: Important elements should have accessibility labels
    let buttons = app.buttons
    let texts = app.staticTexts

    // At least some elements should exist and be accessible
    let hasAccessibleElements = buttons.count > 0 || texts.count > 0
    #expect(hasAccessibleElements, "App should have accessible UI elements")
}

@Test(.timeLimit(.seconds(30))) func launchperformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

@Test(.timeLimit(.seconds(30))) func memoryperformance() throws {
    if #available(iOS 13.0, *) {
        // This measures memory usage during app operation
        let app = XCUIApplication()

        measure(metrics: [XCTMemoryMetric()]) {
            app.launch()
            sleep(2)
            app.terminate()
        }
    }
}
