//
//  NetworkTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import Foundation
@testable import Rhizome
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - URL Construction Tests
    
    @Test func queryfluxurlconstruction() throws {
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
        
        #expect(url.scheme == "https")
        #expect(url.host == "api.fluxhaus.io")
        #expect(url.path == "/")
        #expect(url.user == "rhizome")
        #expect(url.password == password)
    }
    
    @Test func queryfluxurlrequest() throws {
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
        #expect(request.httpMethod == "get")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }
    
    // MARK: - Notification Tests
    
    @Test func loginnotificationposting() throws {
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
        #expect(receivedNotification != nil)
        #expect(receivedNotification?.userInfo?["keysComplete"] != nil)
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    @Test func logoutnotificationposting() throws {
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
        #expect(receivedNotification != nil)
        #expect(receivedNotification?.userInfo?["logout"] != nil)
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - LoginViewModel Tests
    
    @Test func loginviewmodelinitialization() throws {
        // Given & When: Creating LoginViewModel
        let viewModel = LoginViewModel()
        
        // Then: Should initialize with empty password
        #expect(viewModel.password == "")
    }
    
    @Test func loginviewmodelpasswordupdate() throws {
        // Given: LoginViewModel
        var viewModel = LoginViewModel()
        let testPassword = "newPassword123"
        
        // When: Updating password
        viewModel.password = testPassword
        
        // Then: Password should be updated
        #expect(viewModel.password == testPassword)
    }
    
    // MARK: - LoginAction Tests
    
    @Test func loginactioninitialization() throws {
        // Given: LoginRequest parameters
        let request = LoginRequest(password: "testPassword")
        
        // When: Creating LoginAction
        let action = LoginAction(parameters: request)
        
        // Then: Should initialize correctly
        #expect(action.parameters.password == "testPassword")
    }
    
    // MARK: - Performance Tests
    
    @Test func urlconstructionperformance() throws {
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
    
    @Test func notificationperformance() throws {
        measure {
            NotificationCenter.default.post(
                name: .loginsUpdated,
                object: nil,
                userInfo: ["test": true]
            )
        }
    }
}