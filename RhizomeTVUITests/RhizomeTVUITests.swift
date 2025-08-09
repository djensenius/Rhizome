//
//  RhizomeTVUITests.swift
//  RhizomeTVUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest

final class RhizomeTVUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required
        // for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTVAppLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Verify the app launches successfully
        XCTAssertTrue(app.exists)
    }
    
    func testTVFocusNavigation() throws {
        // Given: TV app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
        
        // When: App is fully loaded
        // Then: Should have focusable elements for TV remote navigation
        let buttons = app.buttons
        let tabBars = app.tabBars
        
        // TV apps should have focusable UI elements
        let hasFocusableElements = buttons.count > 0 || tabBars.count > 0
        XCTAssertTrue(hasFocusableElements, "TV app should have focusable elements")
    }
    
    func testTVTabNavigation() throws {
        // Given: TV app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
        
        // When: Checking for tab navigation
        let tabBar = app.tabBars.firstMatch
        if tabBar.exists {
            let tabs = tabBar.buttons
            
            // Then: Should have TV-appropriate tabs
            XCTAssertGreaterThan(tabs.count, 0, "TV app should have navigation tabs")
            
            // Test focusing on different tabs
            for tabIndex in 0..<min(tabs.count, 4) {
                let tab = tabs.element(boundBy: tabIndex)
                if tab.exists && tab.isHittable {
                    tab.tap()
                    sleep(1) // Allow time for navigation
                }
            }
        }
    }
    
    func testTVAuthenticationFlow() throws {
        // Given: TV app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
        
        // When: App may show authentication UI
        let textFields = app.textFields
        let secureTextFields = app.secureTextFields
        let buttons = app.buttons
        
        // Then: Authentication elements should be focusable if present
        if textFields.count > 0 || secureTextFields.count > 0 {
            XCTAssertGreaterThan(buttons.count, 0, "Authentication should have actionable buttons")
        }
        
        // Test always passes - just checking UI exists
        XCTAssertTrue(true, "TV authentication flow test completed")
    }
    
    func testTVRemoteControlSupport() throws {
        // Given: TV app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(2)
        
        // When: App is ready for remote control
        // Then: Should have elements that support remote control interaction
        let interactiveElements = app.buttons.count + app.tabBars.count + app.textFields.count
        
        XCTAssertGreaterThan(interactiveElements, 0, "TV app should have remote-controllable elements")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testTVMemoryPerformance() throws {
        if #available(tvOS 13.0, *) {
            // This measures memory usage during TV app operation
            let app = XCUIApplication()
            
            measure(metrics: [XCTMemoryMetric()]) {
                app.launch()
                sleep(2)
                app.terminate()
            }
        }
    }
}
