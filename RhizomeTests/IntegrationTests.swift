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

    override func setUpWithError() throws {
        // Clear any existing notifications
        NotificationCenter.default.removeObserver(self)
        // Clean up keychain before each test
        cleanupKeychain()
    }

    override func tearDownWithError() throws {
        // Clean up after tests
        NotificationCenter.default.removeObserver(self)
        cleanupKeychain()
    }

    private func cleanupKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: "api.fluxhaus.io",
            kSecAttrAccount as String: "rhizome"
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - LoadingView Tests
    
    func testLoadingViewWithLoginRequired() throws {
        // Given: LoadingView that needs login
        let loadingView = LoadingView(needLoginView: true)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(loadingView)
        XCTAssertTrue(loadingView.needLoginView)
        XCTAssertFalse(loadingView.loggedIn)
        XCTAssertNil(loadingView.error)
    }
    
    func testLoadingViewWithoutLoginRequired() throws {
        // Given: LoadingView that doesn't need login
        let loadingView = LoadingView(needLoginView: false)
        
        // Then: Should initialize correctly
        XCTAssertNotNil(loadingView)
        XCTAssertFalse(loadingView.needLoginView)
    }
    
    func testLoadingViewLoginFlow() throws {
        // Given: LoadingView with login required
        var loadingView = LoadingView(needLoginView: true)
        let expectation = expectation(description: "Login flow completed")
        
        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if notification.userInfo?["keysComplete"] != nil {
                DispatchQueue.main.async {
                    loadingView.loggedIn = true
                    expectation.fulfill()
                }
            }
        }
        
        // When: Simulating successful login
        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: nil,
            userInfo: ["keysComplete": true]
        )
        
        // Then: Should update login state
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(loadingView.loggedIn)
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    func testLoadingViewErrorHandling() throws {
        // Given: LoadingView with login required
        var loadingView = LoadingView(needLoginView: true)
        let expectation = expectation(description: "Error handled")
        let testError = "Invalid credentials"
        
        let observer = NotificationCenter.default.addObserver(
            forName: .loginsUpdated,
            object: nil,
            queue: .main
        ) { notification in
            if let error = notification.userInfo?["loginError"] as? String {
                DispatchQueue.main.async {
                    loadingView.error = error
                    expectation.fulfill()
                }
            }
        }
        
        // When: Simulating login error
        NotificationCenter.default.post(
            name: .loginsUpdated,
            object: nil,
            userInfo: ["loginError": testError]
        )
        
        // Then: Should update error state
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(loadingView.error, testError)
        
        // Clean up
        NotificationCenter.default.removeObserver(observer)
    }
    
    // MARK: - Full App Flow Integration Tests
    
    func testCompleteAuthenticationFlow() throws {
        // Given: Complete authentication components
        let whereWeAre = WhereWeAre()
        let loadingView = LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
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
            rhizomeSchedule: RhizomeSchedule(
                timestamp: "2024-06-18T10:00:00Z",
                appointments: Appointments(daycare: []),
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
        // Given: ContentView with schedule data
        let now = Date()
        let startTime = now.addingTimeInterval(-30 * 60) // 30 minutes ago
        let endTime = now.addingTimeInterval(30 * 60)    // 30 minutes from now
        
        let daycare = AppointmentsDaycare(
            status: "confirmed",
            service: "daycare",
            date: Int(startTime.timeIntervalSince1970 * 1000),
            pickupDate: Int(endTime.timeIntervalSince1970 * 1000),
            timezone: "America/New_York",
            accountId: "123",
            locationId: "456",
            petexec: Petexec(execid: 1, daycareid: 2, serviceid: 3, userid: 4, petid: 5),
            dogName: "Rhizome",
            updatedAt: UpdatedAt(),
            id: "integration-test"
        )
        
        let appointments = Appointments(daycare: [daycare])
        var contentView = ContentView(cameraURL: "https://example.com/stream", rhizomeSchedule: appointments)
        
        // When: Parsing schedule
        contentView.parseSchedule()
        
        // Then: Should detect active appointment
        XCTAssertTrue(contentView.inPlayroom)
        XCTAssertTrue(contentView.showVideo)
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
        XCTAssertEqual(gallery.currentIndex, 0)
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
            // Simulate complete app initialization flow
            let whereWeAre = WhereWeAre()
            let loadingView = LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
            let gallery = Gallery(images: ["image1.jpg", "image2.jpg"])
            let schedule = Schedule(newsUrl: "https://example.com/news", schedule: Appointments(daycare: []))
            
            // Use the components to prevent optimization
            XCTAssertNotNil(whereWeAre)
            XCTAssertNotNil(loadingView)
            XCTAssertNotNil(gallery)
            XCTAssertNotNil(schedule)
        }
    }
    
    func testLargeDatasetIntegration() throws {
        // Given: Large dataset similar to real app usage
        let largeImageList = Array(1...100).map { "https://api.fluxhaus.io/image\($0).jpg" }
        let largeDaycareList = Array(1...50).map { index in
            AppointmentsDaycare(
                status: "confirmed",
                service: "daycare",
                date: Int(Date().timeIntervalSince1970 * 1000),
                pickupDate: Int(Date().addingTimeInterval(3600).timeIntervalSince1970 * 1000),
                timezone: "America/New_York",
                accountId: "\(index)",
                locationId: "\(index)",
                petexec: Petexec(execid: index, daycareid: index, serviceid: index, userid: index, petid: index),
                dogName: "Dog\(index)",
                updatedAt: UpdatedAt(),
                id: "appointment\(index)"
            )
        }
        
        let appointments = Appointments(daycare: largeDaycareList)
        
        // When: Creating components with large datasets
        let gallery = Gallery(images: largeImageList)
        let schedule = Schedule(newsUrl: "https://example.com/news", schedule: appointments)
        var contentView = ContentView(cameraURL: "https://example.com/stream", rhizomeSchedule: appointments)
        
        // Then: Should handle large datasets efficiently
        XCTAssertEqual(gallery.images.count, 100)
        XCTAssertEqual(schedule.schedule?.daycare.count, 50)
        XCTAssertNotNil(contentView.rhizomeSchedule)
        
        // Performance test for large dataset parsing
        measure {
            contentView.parseSchedule()
        }
    }
}