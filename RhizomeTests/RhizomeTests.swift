//
//  RhizomeTests.swift
//  RhizomeTests
//
//  Created by David Jensenius on 2024-06-18.
//

import Testing
@testable import Rhizome
import Foundation

private func cleanupKeychain() {
    let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: "api.fluxhaus.io",
        kSecAttrAccount as String: "rhizome"
    ]
    SecItemDelete(query as CFDictionary)
}

// MARK: - WhereWeAre Tests

@MainActor @Test func whereWeAreDeletePassword() throws {
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

@MainActor @Test func whereWeAreGetPasswordReturnsNilWhenEmpty() throws {
    // Given: No password in keychain
    cleanupKeychain()

    // When: Getting password
    let password = WhereWeAre.getPassword()

    // Then: Should return nil
    #expect(password == nil)
}

// MARK: - System Notifications Tests

@MainActor @Test func systemNotificationNames() throws {
    // Given & When & Then: Notification names should be defined correctly
    #expect(Notification.Name.loginsUpdated.rawValue == "LoginsUpdated")
    #expect(Notification.Name.logout.rawValue == "Logout")
}

// MARK: - Performance Tests

@MainActor @Test(.timeLimit(.minutes(1))) func keychainPerformance() throws {
    // Setup keychain cleanup for performance test
    cleanupKeychain()

    var whereWeAre = WhereWeAre()
    whereWeAre.setPassword(password: "testPassword")
    _ = WhereWeAre.getPassword()
    whereWeAre.deleteKeyChainPasword()

    // Cleanup
    cleanupKeychain()
}

@MainActor @Test(.timeLimit(.minutes(1))) func jsonDecodingPerformance() throws {
    let jsonData = Data("""
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
    """.utf8)

    _ = try? JSONDecoder().decode(LoginResponse.self, from: jsonData)
}
