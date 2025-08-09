//
//  RhizomeTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import XCTest
@testable import Rhizome

final class RhizomeTests: XCTestCase {

    override func setUpWithError() throws {
        // Clean up keychain before each test
        cleanupKeychain()
    }

    override func tearDownWithError() throws {
        // Clean up keychain after each test
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

    // MARK: - WhereWeAre Tests
    
    func testWhereWeAreInitWithoutKeychainPassword() throws {
        // Given: No password in keychain
        cleanupKeychain()
        
        // When: Initializing WhereWeAre
        let whereWeAre = WhereWeAre()
        
        // Then: Should not have keychain password
        XCTAssertFalse(whereWeAre.hasKeyChainPassword)
        XCTAssertTrue(whereWeAre.loading)
    }
    
    func testWhereWeAreSetPassword() throws {
        // Given: A WhereWeAre instance
        var whereWeAre = WhereWeAre()
        let testPassword = "testPassword123"
        
        // When: Setting a password
        whereWeAre.setPassword(password: testPassword)
        
        // Then: Should have keychain password and finished loading
        XCTAssertTrue(whereWeAre.hasKeyChainPassword)
        XCTAssertFalse(whereWeAre.loading)
        
        // And: Password should be retrievable from keychain
        let retrievedPassword = WhereWeAre.getPassword()
        XCTAssertEqual(retrievedPassword, testPassword)
    }
    
    func testWhereWeAreDeletePassword() throws {
        // Given: A password stored in keychain
        var whereWeAre = WhereWeAre()
        let testPassword = "testPassword123"
        whereWeAre.setPassword(password: testPassword)
        
        // When: Deleting the password
        whereWeAre.deleteKeyChainPasword()
        
        // Then: Should not have keychain password and finished loading
        XCTAssertFalse(whereWeAre.hasKeyChainPassword)
        XCTAssertFalse(whereWeAre.loading)
        
        // And: Password should not be retrievable from keychain
        let retrievedPassword = WhereWeAre.getPassword()
        XCTAssertNil(retrievedPassword)
    }
    
    func testWhereWeAreGetPasswordReturnsNilWhenEmpty() throws {
        // Given: No password in keychain
        cleanupKeychain()
        
        // When: Getting password
        let password = WhereWeAre.getPassword()
        
        // Then: Should return nil
        XCTAssertNil(password)
    }

    // MARK: - Model Tests
    
    func testLoginResponseDecoding() throws {
        // Given: Valid JSON data
        let jsonData = """
        {
            "cameraURL": "https://example.com/stream",
            "rhizomeSchedule": {
                "timestamp": "2024-06-18T10:00:00Z",
                "appointments": {
                    "daycare": []
                }
            },
            "rhizomeData": {
                "timestamp": "2024-06-18T10:00:00Z",
                "news": "Test news",
                "photos": ["photo1.jpg", "photo2.jpg"]
            }
        }
        """.data(using: .utf8)!
        
        // When: Decoding the data
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
        
        // Then: Should decode correctly
        XCTAssertEqual(loginResponse.cameraURL, "https://example.com/stream")
        XCTAssertEqual(loginResponse.rhizomeData.news, "Test news")
        XCTAssertEqual(loginResponse.rhizomeData.photos.count, 2)
        XCTAssertEqual(loginResponse.rhizomeData.photos[0], "photo1.jpg")
    }
    
    func testAppointmentsDaycareDecoding() throws {
        // Given: Valid daycare appointment JSON
        let jsonData = """
        {
            "status": "confirmed",
            "service": "daycare",
            "date": 1719489600000,
            "pickupDate": 1719518400000,
            "timezone": "America/New_York",
            "accountId": "123",
            "locationId": "456",
            "petexec": {
                "execid": 1,
                "daycareid": 2,
                "serviceid": 3,
                "userid": 4,
                "petid": 5
            },
            "dogName": "Rhizome",
            "updatedAt": {},
            "id": "appointment123"
        }
        """.data(using: .utf8)!
        
        // When: Decoding the data
        let appointment = try JSONDecoder().decode(AppointmentsDaycare.self, from: jsonData)
        
        // Then: Should decode correctly
        XCTAssertEqual(appointment.status, "confirmed")
        XCTAssertEqual(appointment.service, "daycare")
        XCTAssertEqual(appointment.dogName, "Rhizome")
        XCTAssertEqual(appointment.timezone, "America/New_York")
        XCTAssertEqual(appointment.petexec.execid, 1)
    }

    // MARK: - System Notifications Tests
    
    func testSystemNotificationNames() throws {
        // Given & When & Then: Notification names should be defined correctly
        XCTAssertEqual(Notification.Name.loginsUpdated.rawValue, "LoginsUpdated")
        XCTAssertEqual(Notification.Name.logout.rawValue, "Logout")
    }

    // MARK: - Performance Tests
    
    func testKeychainPerformance() throws {
        measure {
            var whereWeAre = WhereWeAre()
            whereWeAre.setPassword(password: "testPassword")
            _ = WhereWeAre.getPassword()
            whereWeAre.deleteKeyChainPasword()
        }
    }
    
    func testJSONDecodingPerformance() throws {
        let jsonData = """
        {
            "cameraURL": "https://example.com/stream",
            "rhizomeSchedule": {
                "timestamp": "2024-06-18T10:00:00Z",
                "appointments": {
                    "daycare": []
                }
            },
            "rhizomeData": {
                "timestamp": "2024-06-18T10:00:00Z",
                "news": "Test news",
                "photos": ["photo1.jpg", "photo2.jpg"]
            }
        }
        """.data(using: .utf8)!
        
        measure {
            _ = try? JSONDecoder().decode(LoginResponse.self, from: jsonData)
        }
    }
}
