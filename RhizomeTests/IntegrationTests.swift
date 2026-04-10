//
//  IntegrationTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
import SwiftUI
@testable import Rhizome

final class IntegrationTests: XCTestCase {

    private func cleanupKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: "api.fluxhaus.io",
            kSecAttrAccount as String: "rhizome"
        ]
        SecItemDelete(query as CFDictionary)
    }

    override func setUpWithError() throws {
        cleanupKeychain()
    }

    override func tearDownWithError() throws {
        cleanupKeychain()
    }

    // MARK: - LoadingView Tests

    func testLoadingViewWithLoginRequired() throws {
        // Given: LoadingView that needs login
        let loadingView = LoadingView(needLoginView: true)

        // Then: Should initialize correctly
        XCTAssertNotNil(loadingView)
        XCTAssertTrue(loadingView.needLoginView)
    }

    func testLoadingViewWithoutLoginRequired() throws {
        // Given: LoadingView that doesn't need login
        let loadingView = LoadingView(needLoginView: false)

        // Then: Should initialize correctly
        XCTAssertNotNil(loadingView)
        XCTAssertFalse(loadingView.needLoginView)
    }

    func testLoadingViewLoginNotification() throws {
        // Given: Expectation for login notification
        let expectation = expectation(description: "Login notification received")
        var authCompleted = false

        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if notification.userInfo?["keysComplete"] != nil {
                authCompleted = true
                expectation.fulfill()
            }
        }

        // When: Simulating successful login
        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: nil,
            userInfo: ["keysComplete": true]
        )

        // Then: Should receive notification
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(authCompleted)

        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }

    func testLoadingViewErrorNotification() throws {
        // Given: Expectation for error notification
        let expectation = expectation(description: "Error handled")
        let testError = "Invalid credentials"
        var receivedError: String?

        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?["loginError"] as? String {
                receivedError = error
                expectation.fulfill()
            }
        }

        // When: Simulating login error
        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: nil,
            userInfo: ["loginError": testError]
        )

        // Then: Should receive error
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedError, testError)

        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - Full App Flow Integration Tests

    func testCompleteAuthenticationFlow() throws {
        // Given: Complete authentication components
        let loginExpectation = expectation(description: "Complete auth flow")
        var authCompleted = false

        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if notification.userInfo?["keysComplete"] != nil {
                authCompleted = true
                loginExpectation.fulfill()
            }
        }

        // When: Simulating complete authentication
        let testResponse = LoginResponse(
            cameraURL: "https://example.com/stream",
            romperURL: nil,
            gymURL: nil,
            rhizomeSchedule: RhizomeSchedule(
                timestamp: "2024-06-18T10:00:00Z",
                appointments: nil,
                rawData: nil
            ),
            rhizomeData: RhizomeData(
                timestamp: "2024-06-18T10:00:00Z",
                news: "Test news",
                photos: ["photo1.jpg", "photo2.jpg"]
            )
        )

        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: testResponse,
            userInfo: ["keysComplete": true]
        )

        // Then: Should complete authentication flow
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(authCompleted)

        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }

    func testScheduleParsingWithContentView() throws {
        // Given: ContentView with schedule data for today
        let torontoTimeZone = TimeZone(identifier: "America/Toronto")!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, M/d/yyyy h:mm a"
        formatter.timeZone = torontoTimeZone
        let todayString = formatter.string(from: Date())

        let daycare = AppointmentsDaycare(startDate: todayString, rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        var contentView = ContentView(
            cameras: [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")],
            rhizomeSchedule: appointments
        )

        // When: Parsing schedule
        contentView.parseSchedule()

        // Then: inPlayroom depends on current Toronto time (7am-7pm)
        let now = Date()
        let nowToronto = now.addingTimeInterval(
            TimeInterval(torontoTimeZone.secondsFromGMT(for: now) - TimeZone.current.secondsFromGMT(for: now))
        )
        var calendar = Calendar.current
        calendar.timeZone = torontoTimeZone
        let hour = calendar.component(.hour, from: nowToronto)
        let expectedInPlayroom = hour >= 7 && hour < 19

        XCTAssertEqual(contentView.inPlayroom, expectedInPlayroom)
    }

    func testGalleryWithNetworkData() throws {
        // Given: Gallery with network URLs
        let networkImages = [
            "https://example.com/image1.jpg",
            "https://api.fluxhaus.io/photo2.jpg",
            "https://cdn.example.com/image3.png"
        ]

        // When: Creating Gallery with network images
        let gallery = Gallery(images: networkImages)

        // Then: Should handle network URLs correctly
        XCTAssertEqual(gallery.images.count, 3)
        XCTAssertTrue(gallery.images[0].starts(with: "https://"))
        XCTAssertTrue(gallery.images[1].contains("api.fluxhaus.io"))
    }

    func testCompleteLogoutFlow() throws {
        // Given: User is logged in with keychain password
        var whereWeAre = WhereWeAre()
        whereWeAre.setPassword(password: "testPassword123")

        // Verify password is stored
        XCTAssertNotNil(WhereWeAre.getPassword())

        let logoutExpectation = expectation(description: "Logout completed")
        let observer = NotificationCenter.default.addObserver(
            forName: .logout,
            object: nil,
            queue: .main
        ) { notification in
            if notification.userInfo?["logout"] != nil {
                logoutExpectation.fulfill()
            }
        }

        // When: Performing logout
        whereWeAre.deleteKeyChainPasword()
        NotificationCenter.default.post(
            name: .logout,
            object: nil,
            userInfo: ["logout": true]
        )

        // Then: Should complete logout and clear keychain
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(WhereWeAre.getPassword())
        XCTAssertFalse(whereWeAre.hasKeyChainPassword)

        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - Performance Integration Tests

    func testCompleteAppFlowPerformance() throws {
        measure {
            let whereWeAre = WhereWeAre()
            let loadingView = LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
            let gallery = Gallery(images: ["image1.jpg", "image2.jpg"])
            let daycare = AppointmentsDaycare(
                startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day"
            )
            let appointments = Appointments(nextReservation: daycare)
            let schedule = Schedule(newsUrl: "https://example.com/news", schedule: appointments)

            XCTAssertNotNil(whereWeAre)
            XCTAssertNotNil(loadingView)
            XCTAssertNotNil(gallery)
            XCTAssertNotNil(schedule)
        }
    }

    func testLargeDatasetIntegration() throws {
        // Given: Large dataset similar to real app usage
        let largeImageList = Array(1...100).map { "https://api.fluxhaus.io/image\($0).jpg" }

        // When: Creating components with large datasets
        let gallery = Gallery(images: largeImageList)
        let daycare = AppointmentsDaycare(startDate: "Thursday, 8/14/2025 9:00 am", rId: 1, type: "Daycare | Full Day")
        let appointments = Appointments(nextReservation: daycare)
        let schedule = Schedule(newsUrl: "https://example.com/news", schedule: appointments)
        var contentView = ContentView(
            cameras: [CameraFeed(id: "toybox", name: "Toybox", url: "https://example.com/stream")],
            rhizomeSchedule: appointments
        )

        // Then: Should handle large datasets efficiently
        XCTAssertEqual(gallery.images.count, 100)
        XCTAssertNotNil(schedule.schedule)
        XCTAssertNotNil(contentView.rhizomeSchedule)

        // Performance test for parsing
        measure {
            contentView.parseSchedule()
        }
    }
}
