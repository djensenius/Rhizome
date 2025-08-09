//
//  RhizomeTVTests.swift
//  RhizomeTVTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import AuthenticationServices
import SwiftUI
@testable import RhizomeTV

final class RhizomeTVTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - AuthenticationController Tests
    
    func testAuthenticationControllerInitialization() throws {
        // Given & When: Creating AuthenticationController
        let controller = AuthenticationController()
        
        // Then: Should initialize with ready state
        XCTAssertEqual(controller.state, .ready)
        XCTAssertNotNil(controller.viewModel)
    }
    
    func testAuthenticationControllerSignIn() throws {
        // Given: AuthenticationController
        let controller = AuthenticationController()
        let email = "test@example.com"
        let password = "testPassword"
        
        // When: Signing in
        controller.signIn(email: email, password: password)
        
        // Then: Should update state and viewModel
        if case .authenticated(let user) = controller.state {
            XCTAssertEqual(user, "loggedIn")
        } else {
            XCTFail("Expected authenticated state")
        }
        XCTAssertEqual(controller.viewModel.password, password)
    }
    
    // MARK: - AuthenticationState Tests
    
    func testAuthenticationStateReady() throws {
        // Given & When: Ready state
        let state = AuthenticationState.ready
        
        // Then: Should have correct properties
        XCTAssertFalse(state.wantsManualPasswordAuthentication)
        XCTAssertNil(state.error)
        XCTAssertNil(state.user)
    }
    
    func testAuthenticationStateAuthenticating() throws {
        // Given & When: Authenticating state
        let state = AuthenticationState.authenticating
        
        // Then: Should have correct properties
        XCTAssertFalse(state.wantsManualPasswordAuthentication)
        XCTAssertNil(state.error)
        XCTAssertNil(state.user)
    }
    
    func testAuthenticationStateWantsManualPasswordAuthentication() throws {
        // Given & When: Manual password authentication state
        let state = AuthenticationState.wantsManualPasswordAuthentication
        
        // Then: Should have correct properties
        XCTAssertTrue(state.wantsManualPasswordAuthentication)
        XCTAssertNil(state.error)
        XCTAssertNil(state.user)
    }
    
    func testAuthenticationStateAuthenticated() throws {
        // Given & When: Authenticated state
        let user = "testUser"
        let state = AuthenticationState.authenticated(user)
        
        // Then: Should have correct properties
        XCTAssertFalse(state.wantsManualPasswordAuthentication)
        XCTAssertNil(state.error)
        XCTAssertEqual(state.user, user)
    }
    
    func testAuthenticationStateFailed() throws {
        // Given & When: Failed state
        let error = AuthenticationError.cancelled
        let state = AuthenticationState.failed(error)
        
        // Then: Should have correct properties
        XCTAssertFalse(state.wantsManualPasswordAuthentication)
        XCTAssertNotNil(state.error)
        XCTAssertNil(state.user)
    }
    
    func testAuthenticationStateReset() throws {
        // Given: A non-ready state
        var state = AuthenticationState.authenticating
        
        // When: Resetting state
        state.reset()
        
        // Then: Should be ready
        XCTAssertEqual(state, .ready)
    }
    
    // MARK: - AuthenticationError Tests
    
    func testAuthenticationErrorCancelled() throws {
        // Given & When: Cancelled error
        let error = AuthenticationError.cancelled
        
        // Then: Should be cancelled
        XCTAssertTrue(error.isCancelledError)
        XCTAssertNotNil(error.errorDescription)
    }
    
    func testAuthenticationErrorUnknown() throws {
        // Given: Unknown error
        let underlyingError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        let error = AuthenticationError.unknown(underlyingError)
        
        // When & Then: Should not be cancelled
        XCTAssertFalse(error.isCancelledError)
        XCTAssertNotNil(error.errorDescription)
    }
    
    func testAuthenticationErrorInitWithCancelledError() throws {
        // Given: ASAuthorization cancelled error
        let asError = ASAuthorizationError(.canceled)
        
        // When: Creating AuthenticationError
        let error = AuthenticationError(asError)
        
        // Then: Should be cancelled
        XCTAssertTrue(error.isCancelledError)
    }
    
    func testAuthenticationErrorInitWithOtherError() throws {
        // Given: Other error
        let otherError = NSError(domain: "TestDomain", code: 456, userInfo: nil)
        
        // When: Creating AuthenticationError
        let error = AuthenticationError(otherError)
        
        // Then: Should not be cancelled
        XCTAssertFalse(error.isCancelledError)
    }
    
    // MARK: - RhizomeTabs Tests
    
    func testRhizomeTabsInitialization() throws {
        // Given: RhizomeTabs parameters
        let cameraUrl = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        let newsUrl = "https://example.com/news"
        let images = ["image1.jpg", "image2.jpg"]
        
        // When: Creating RhizomeTabs
        let tabs = RhizomeTabs(
            cameraUrl: cameraUrl,
            rhizomeSchedule: appointments,
            newsUrl: newsUrl,
            images: images
        )
        
        // Then: Should initialize correctly
        XCTAssertNotNil(tabs)
        XCTAssertEqual(tabs.cameraUrl, cameraUrl)
        XCTAssertEqual(tabs.newsUrl, newsUrl)
        XCTAssertEqual(tabs.images.count, 2)
    }
    
    // MARK: - Performance Tests
    
    func testAuthenticationControllerPerformance() throws {
        measure {
            let controller = AuthenticationController()
            controller.signIn(email: "test@example.com", password: "testPassword")
        }
    }
    
    func testRhizomeTabsPerformance() throws {
        let cameraUrl = "https://example.com/stream"
        let appointments = Appointments(daycare: [])
        let newsUrl = "https://example.com/news"
        let images = Array(1...50).map { "image\($0).jpg" }
        
        measure {
            let _ = RhizomeTabs(
                cameraUrl: cameraUrl,
                rhizomeSchedule: appointments,
                newsUrl: newsUrl,
                images: images
            )
        }
    }
}
