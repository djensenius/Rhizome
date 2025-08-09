//
//  RhizomeTVTests.swift
//  RhizomeTVTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import AuthenticationServices
import SwiftUI
@testable import RhizomeTV

// MARK: - AuthenticationController Tests

@Test func authenticationControllerInitialization() throws {
    // Given & When: Creating AuthenticationController
    let controller = AuthenticationController()

    // Then: Should initialize with ready state
    #expect(controller.state == .ready)
    #expect(controller.viewModel != nil)
}

@Test func authenticationControllerSignIn() throws {
    // Given: AuthenticationController
    let controller = AuthenticationController()
    let email = "test@example.com"
    let password = "testPassword"

    // When: Signing in
    controller.signIn(email: email, password: password)

    // Then: Should update state and viewModel
    if case .authenticated(let user) = controller.state {
        #expect(user == "loggedIn")
    } else {
        #expect(Bool(false), "Expected authenticated state")
    }
    #expect(controller.viewModel.password == password)
}

// MARK: - AuthenticationState Tests

@Test func authenticationStateReady() throws {
    // Given & When: Ready state
    let state = AuthenticationState.ready

    // Then: Should have correct properties
    #expect(!state.wantsManualPasswordAuthentication)
    #expect(state.error == nil)
    #expect(state.user == nil)
}

@Test func authenticationStateAuthenticating() throws {
    // Given & When: Authenticating state
    let state = AuthenticationState.authenticating

    // Then: Should have correct properties
    #expect(!state.wantsManualPasswordAuthentication)
    #expect(state.error == nil)
    #expect(state.user == nil)
}

@Test func authenticationStateWantsManualPasswordAuthentication() throws {
    // Given & When: Manual password authentication state
    let state = AuthenticationState.wantsManualPasswordAuthentication

    // Then: Should have correct properties
    #expect(state.wantsManualPasswordAuthentication)
    #expect(state.error == nil)
    #expect(state.user == nil)
}

@Test func authenticationStateAuthenticated() throws {
    // Given & When: Authenticated state
    let user = "testUser"
    let state = AuthenticationState.authenticated(user)

    // Then: Should have correct properties
    #expect(!state.wantsManualPasswordAuthentication)
    #expect(state.error == nil)
    #expect(state.user == user)
}

@Test func authenticationStateFailed() throws {
    // Given & When: Failed state
    let error = AuthenticationError.cancelled
    let state = AuthenticationState.failed(error)

    // Then: Should have correct properties
    #expect(!state.wantsManualPasswordAuthentication)
    #expect(state.error != nil)
    #expect(state.user == nil)
}

@Test func authenticationStateReset() throws {
    // Given: A non-ready state
    var state = AuthenticationState.authenticating

    // When: Resetting state
    state.reset()

    // Then: Should be ready
    #expect(state == .ready)
}

// MARK: - AuthenticationError Tests

@Test func authenticationErrorCancelled() throws {
    // Given & When: Cancelled error
    let error = AuthenticationError.cancelled

    // Then: Should be cancelled
    #expect(error.isCancelledError)
    #expect(error.errorDescription != nil)
}

@Test func authenticationErrorUnknown() throws {
    // Given: Unknown error
    let underlyingError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
    let error = AuthenticationError.unknown(underlyingError)

    // When & Then: Should not be cancelled
    #expect(!error.isCancelledError)
    #expect(error.errorDescription != nil)
}

@Test func authenticationErrorInitWithCancelledError() throws {
    // Given: ASAuthorization cancelled error
    let asError = ASAuthorizationError(.canceled)

    // When: Creating AuthenticationError
    let error = AuthenticationError(asError)

    // Then: Should be cancelled
    #expect(error.isCancelledError)
}

@Test func authenticationErrorInitWithOtherError() throws {
    // Given: Other error
    let otherError = NSError(domain: "TestDomain", code: 456, userInfo: nil)

    // When: Creating AuthenticationError
    let error = AuthenticationError(otherError)

    // Then: Should not be cancelled
    #expect(!error.isCancelledError)
}

// MARK: - RhizomeTabs Tests

@Test func rhizomeTabsInitialization() throws {
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
    #expect(tabs != nil)
    #expect(tabs.cameraUrl == cameraUrl)
    #expect(tabs.newsUrl == newsUrl)
    #expect(tabs.images.count == 2)
}

// MARK: - Performance Tests

@Test(.timeLimit(.seconds(5))) func authenticationControllerPerformance() throws {
    let controller = AuthenticationController()
    controller.signIn(email: "test@example.com", password: "testPassword")
}

@Test(.timeLimit(.seconds(5))) func rhizomeTabsPerformance() throws {
    let cameraUrl = "https://example.com/stream"
    let appointments = Appointments(daycare: [])
    let newsUrl = "https://example.com/news"
    let images = Array(1...50).map { "image\($0).jpg" }

    _ = RhizomeTabs(
        cameraUrl: cameraUrl,
        rhizomeSchedule: appointments,
        newsUrl: newsUrl,
        images: images
    )
}
