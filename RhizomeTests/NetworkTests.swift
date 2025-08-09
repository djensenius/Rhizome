//
//  NetworkTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
import Foundation
@testable import Rhizome

@Suite("Network Tests")
struct NetworkTests {

    // MARK: - URL Construction Tests

    @Test
    func queryfluxurlconstruction() {
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
        let url: URL = #require(components.url, "URL construction failed")

        #expect(url.scheme == "https")
        #expect(url.host == "api.fluxhaus.io")
        #expect(url.path == "/")
        #expect(url.user == "rhizome")
        #expect(url.password == password)
    }

    @Test
    func queryfluxurlrequest() {
        // Given: Valid URL components
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.fluxhaus.io"
        components.path = "/"
        components.user = "rhizome"
        components.password = "testPassword"

        let url: URL = #require(components.url, "URL construction failed")

        // When: Creating URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "get" // keep as in original test
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // Then: Request should be configured correctly
        #expect(request.httpMethod == "get")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    // MARK: - Notification Tests

    @Test
    func loginnotificationposting() async {
        // Given: Prepare async listener for the notification
        let center = NotificationCenter.default
        let sequence = center.notifications(named: .loginsUpdated)
        var iterator = sequence.makeAsyncIterator()
        async let next = iterator.next()

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

        center.post(
            name: .loginsUpdated,
            object: testResponse,
            userInfo: ["keysComplete": true]
        )

        // Then: Notification should be received
        let received = await next
        #expect(received != nil)
        #expect((received?.userInfo?["keysComplete"] as? Bool) == true)
        #expect(received?.object is LoginResponse)
    }

    @Test
    func logoutnotificationposting() async {
        // Given: Prepare async listener for the notification
        let center = NotificationCenter.default
        let sequence = center.notifications(named: .logout)
        var iterator = sequence.makeAsyncIterator()
        async let next = iterator.next()

        // When: Posting logout notification
        center.post(
            name: .logout,
            object: nil,
            userInfo: ["logout": true]
        )

        // Then: Notification should be received
        let received = await next
        #expect(received != nil)
        #expect((received?.userInfo?["logout"] as? Bool) == true)
    }

    // MARK: - LoginViewModel Tests

    @Test
    func loginviewmodelinitialization() {
        // Given & When: Creating LoginViewModel
        let viewModel = LoginViewModel()

        // Then: Should initialize with empty password
        #expect(viewModel.password == "")
    }

    @Test
    func loginviewmodelpasswordupdate() {
        // Given: LoginViewModel
        var viewModel = LoginViewModel()
        let testPassword = "newPassword123"

        // When: Updating password
        viewModel.password = testPassword

        // Then: Password should be updated
        #expect(viewModel.password == testPassword)
    }

    // MARK: - LoginAction Tests

    @Test
    func loginactioninitialization() {
        // Given: LoginRequest parameters
        let request = LoginRequest(password: "testPassword")

        // When: Creating LoginAction
        let action = LoginAction(parameters: request)

        // Then: Should initialize correctly
        #expect(action.parameters.password == "testPassword")
    }

    // MARK: - Performance Tests

    @Test
    func urlconstructionperformance() {
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

    @Test
    func notificationperformance() {
        let center = NotificationCenter.default
        measure {
            center.post(
                name: .loginsUpdated,
                object: nil,
                userInfo: ["test": true]
            )
        }
    }
}
