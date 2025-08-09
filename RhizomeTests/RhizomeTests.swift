//
//  RhizomeTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
@testable import Rhizome

private func cleanupKeychain() {
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: "api.fluxhaus.io",
        kSecAttrAccount as String: "rhizome"
    ]
    SecItemDelete(query as CFDictionary)
}

// MARK: - WhereWeAre Tests

@Test func whereWeAreInitWithoutKeychainPassword() throws {
    // Given: No password in keychain
    cleanupKeychain()
    
    // When: Initializing WhereWeAre
    let whereWeAre = WhereWeAre()
    
    // Then: Should not have keychain password
    #expect(!whereWeAre.hasKeyChainPassword)
    #expect(whereWeAre.loading)
}

@Test func whereWeAreSetPassword() throws {
    // Given: A WhereWeAre instance
    cleanupKeychain()
    var whereWeAre = WhereWeAre()
    let testPassword = "testPassword123"
    
    // When: Setting a password
    whereWeAre.setPassword(password: testPassword)
    
    // Then: Should have keychain password and finished loading
    #expect(whereWeAre.hasKeyChainPassword)
    #expect(!whereWeAre.loading)
    
    // And: Password should be retrievable from keychain
    let retrievedPassword = WhereWeAre.getPassword()
    #expect(retrievedPassword == testPassword)
    
    // Cleanup
    cleanupKeychain()
}
@Test func whereWeAreDeletePassword() throws {
    // Given: A password stored in keychain
    cleanupKeychain()
    var whereWeAre = WhereWeAre()
    let testPassword = "testPassword123"
    whereWeAre.setPassword(password: testPassword)
    
    // When: Deleting the password
    whereWeAre.deleteKeyChainPasword()
    
    // Then: Should not have keychain password and finished loading
    #expect(!whereWeAre.hasKeyChainPassword)
    #expect(!whereWeAre.loading)
    
    // And: Password should not be retrievable from keychain
    let retrievedPassword = WhereWeAre.getPassword()
    #expect(retrievedPassword == nil)
    
    // Cleanup
    cleanupKeychain()
}

@Test func whereWeAreGetPasswordReturnsNilWhenEmpty() throws {
    // Given: No password in keychain
    cleanupKeychain()
    
    // When: Getting password
    let password = WhereWeAre.getPassword()
    
    // Then: Should return nil
    #expect(password == nil)
}

// MARK: - Model Tests

@Test func loginResponseDecoding() throws {
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
    #expect(loginResponse.cameraURL == "https://example.com/stream")
    #expect(loginResponse.rhizomeData.news == "Test news")
    #expect(loginResponse.rhizomeData.photos.count == 2)
    #expect(loginResponse.rhizomeData.photos[0] == "photo1.jpg")
}
@Test func appointmentsDaycareDecoding() throws {
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
    #expect(appointment.status == "confirmed")
    #expect(appointment.service == "daycare")
    #expect(appointment.dogName == "Rhizome")
    #expect(appointment.timezone == "America/New_York")
    #expect(appointment.petexec.execid == 1)
}

// MARK: - System Notifications Tests

@Test func systemNotificationNames() throws {
    // Given & When & Then: Notification names should be defined correctly
    #expect(Notification.Name.loginsUpdated.rawValue == "LoginsUpdated")
    #expect(Notification.Name.logout.rawValue == "Logout")
}

// MARK: - Performance Tests

@Test(.timeLimit(.seconds(5))) func keychainPerformance() throws {
    // Setup keychain cleanup for performance test
    cleanupKeychain()
    
    var whereWeAre = WhereWeAre()
    whereWeAre.setPassword(password: "testPassword")
    _ = WhereWeAre.getPassword()
    whereWeAre.deleteKeyChainPasword()
    
    // Cleanup
    cleanupKeychain()
}

@Test(.timeLimit(.seconds(5))) func jsonDecodingPerformance() throws {
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
    
    _ = try? JSONDecoder().decode(LoginResponse.self, from: jsonData)
}
