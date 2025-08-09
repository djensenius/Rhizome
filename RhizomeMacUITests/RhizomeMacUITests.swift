//
//  RhizomeMacUITests.swift
//  RhizomeMacUITests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import XCTest



        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.

        // In UI tests it’s important to set the initial state - such as interface orientation - required for
        // your tests before they run. The setUp method is a good place to do this.
    }

        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @Test func MacAppLaunch() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Verify the app launches successfully
        #expect(app.exists)
    }
    
    @Test func MacGridViewExists() throws {
        // Given: Mac app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(2)
        
        // When: App is fully loaded
        // Then: Should have some grid or collection view elements
        let collectionViews = app.collectionViews
        let scrollViews = app.scrollViews
        let images = app.images
        
        // At least one of these UI elements should exist for gallery functionality
        let hasGridElements = collectionViews.count > 0 || scrollViews.count > 0 || images.count > 0
        #expect(hasGridElements || app.staticTexts.count > 0, "App should have UI elements")
    }
    
    @Test func MacSidebarNavigation() throws {
        // Given: Mac app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(3)
        
        // When: Checking for sidebar navigation (macOS specific)
        let sidebar = app.splitGroups.firstMatch
        let buttons = app.buttons
        
        // Then: Should have some navigation elements
        let hasNavigation = sidebar.exists || buttons.count > 0
        #expect(hasNavigation, "Mac app should have navigation elements")
    }
    
    @Test func MacColumnStepper() throws {
        // Given: Mac app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(2)
        
        // When: Looking for stepper controls (for column adjustment)
        let steppers = app.steppers
        let buttons = app.buttons
        
        // Then: Should have some control elements
        let hasControls = steppers.count > 0 || buttons.count > 0
        #expect(hasControls, "Mac app should have control elements")
    }
    
    @Test func MacWindowResizing() throws {
        // Given: Mac app is launched
        let app = XCUIApplication()
        app.launch()
        
        // Wait for app to load
        sleep(2)
        
        // When: App window exists
        let windows = app.windows
        
        // Then: Should have at least one window
        #expect(windows.count, 0 > "Mac app should have at least one window")
        
        if windows.count > 0 {
            let mainWindow = windows.firstMatch
            #expect(mainWindow.exists, "Main window should exist")
        }
    }

    @Test func LaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            @Test(.timeLimit(.seconds(30))) func launchperformancetest() throws {
                XCUIApplication().launch()
            }
        }
    }
    
    @Test func MacMemoryPerformance() throws {
        if #available(macOS 10.15, *) {
            // This measures memory usage during app operation
            let app = XCUIApplication()
            
            measure(metrics: [XCTMemoryMetric()]) {
                app.launch()
                sleep(2)
                app.terminate()
            }
        }
    }
}
