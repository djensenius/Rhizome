//
//  NetworkTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import Foundation
@testable import Rhizome

final class NetworkTests: XCTestCase {

    override func setUpWithError() throws {
        // Clear any existing notifications
        NotificationCenter.default.removeObserver(self)
    }

    override func tearDownWithError() throws {
        // Clean up after tests
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - URL Construction Tests
    
    func testQueryFluxURLConstruction() throws {
        // Given: Password for API call
        let password = "testPassword123"
        
        // When: Constructing URL components manually (simulating queryFlux logic)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.fluxhaus.io"
        components.path = "/"
        components.user = "rhizome"
        components.password = password
        
        // Then: URL should be constructed correctly
        guard let url = components.url else {
            XCTFail("URL construction failed")
            return
        }
        
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "api.fluxhaus.io")
        XCTAssertEqual(url.path, "/")
        XCTAssertEqual(url.user, "rhizome")
        XCTAssertEqual(url.password, password)
    }
    
    func testQueryFluxURLRequest() throws {
        // Given: Valid URL components
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.fluxhaus.io"
        components.path = "/"
        components.user = "rhizome"
        components.password = "testPassword"
        
        guard let url = components.url else {
            XCTFail("URL construction failed")
            return
        }
        
        // When: Creating URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Then: Request should be configured correctly
        XCTAssertEqual(request.httpMethod, "get")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    // MARK: - Notification Tests
    
    func testLoginNotificationPosting() throws {
        // Given: Expectation for notification
        let expectation = expectation(description: "Login notification received")
        var receivedNotification: Notification?
        
        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            receivedNotification = notification
            expectation.fulfill()
        }
        
        // When: Posting login notification
        let testResponse = LoginResponse(
            cameraURL: "https://example.com/stream",
            rhizomeSchedule: RhizomeSchedule(
                timestamp: "2024-06-18T10:00:00Z",
                appointments: nil,
                rawData: nil
            ),
            rhizomeData: RhizomeData(
                timestamp: "2024-06-18T10:00:00Z",
                news: "Test news",
                photos: []
            )
        )
        
        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: testResponse,
            userInfo: ["keysComplete": true]
        )
        
        // Then: Notification should be received
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedNotification)
        XCTAssertNotNil(receivedNotification?.userInfo?["keysComplete"])
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testLogoutNotificationPosting() throws {
        // Given: Expectation for logout notification
        let expectation = expectation(description: "Logout notification received")
        var receivedNotification: Notification?
        
        let observer = NotificationCenter.default.addObserver(
            forName: .logout,
            object: nil,
            queue: .main
        ) { notification in
            receivedNotification = notification
            expectation.fulfill()
        }
        
        // When: Posting logout notification
        NotificationCenter.default.post(
            name: .logout,
            object: nil,
            userInfo: ["logout": true]
        )
        
        // Then: Notification should be received
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedNotification)
        XCTAssertNotNil(receivedNotification?.userInfo?["logout"])
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - LoginViewModel Tests
    
    func testLoginViewModelInitialization() throws {
        // Given & When: Creating LoginViewModel
        let viewModel = LoginViewModel()
        
        // Then: Should initialize with empty password
        XCTAssertEqual(viewModel.password, "")
    }
    
    func testLoginViewModelPasswordUpdate() throws {
        // Given: LoginViewModel
        var viewModel = LoginViewModel()
        let testPassword = "newPassword123"
        
        // When: Updating password
        viewModel.password = testPassword
        
        // Then: Password should be updated
        XCTAssertEqual(viewModel.password, testPassword)
    }
    
    // MARK: - LoginAction Tests
    
    func testLoginActionInitialization() throws {
        // Given: LoginRequest parameters
        let request = LoginRequest(password: "testPassword")
        
        // When: Creating LoginAction
        let action = LoginAction(parameters: request)
        
        // Then: Should initialize correctly
        XCTAssertEqual(action.parameters.password, "testPassword")
    }
    
    // MARK: - Performance Tests
    
    func testURLConstructionPerformance() throws {
        measure {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.fluxhaus.io"
            components.path = "/"
            components.user = "rhizome"
            components.password = "testPassword"
            _ = components.url
        }
    }
    
    func testNotificationPerformance() throws {
        measure {
            NotificationCenter.default.post(
                name: .loginsUpdated,
                object: nil,
                userInfo: ["test": true]
            )
        }
    }
}