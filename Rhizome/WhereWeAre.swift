//
//  WhereWeAre.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-19.
//

import Foundation

struct WhereWeAre {
    var hasKeyChainPassword = false
    var loading = true

    // Check if user exists in the keychain
    init() {
        let password = WhereWeAre.getPassword()
        if password != nil {
            queryFlux(password: password!)
            hasKeychainPassword(has: true)
        } else {
            hasKeychainPassword(has: false)
        }
    }

    mutating func setPassword(password: String) {
        // Set attributes
        var attributes: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: "api.fluxhaus.io",
            kSecAttrAccount as String: "rhizome",
            kSecValueData as String: password.data(using: String.Encoding.utf8)!,
            kSecAttrAccessGroup as String: "org.davidjensenius.Rhizome"
        ]
        // Add user
        var status = SecItemAdd(attributes as CFDictionary, nil)

        if status == noErr {
            print("User saved successfully in the keychain")
        } else {
            attributes = [
                kSecClass as String: kSecClassInternetPassword,
                kSecAttrServer as String: "api.fluxhaus.io",
                kSecAttrAccount as String: "rhizome",
                kSecValueData as String: password.data(using: String.Encoding.utf8)!
            ]
            // Add user
             status = SecItemAdd(attributes as CFDictionary, nil)
            if status == noErr {
                print("User saved successfully in the keychain without access group")
            }
        }

        hasKeychainPassword(has: true)
        finishedLoading()
    }

    static func getPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: "rhizome",
            kSecAttrServer as String: "api.fluxhaus.io",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?

        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let passwordData = existingItem[kSecValueData as String] as? Data,
               let password = String(data: passwordData, encoding: .utf8) {
                return password
            }
        }
        return nil
    }

    mutating func hasKeychainPassword(has: Bool) {
        hasKeyChainPassword = has
    }

    mutating func finishedLoading() {
        loading = false
    }

    mutating func deleteKeyChainPasword() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: "api.fluxhaus.io",
            kSecAttrAccount as String: "rhizome"
        ]
        // Find user and delete
        if SecItemDelete(query as CFDictionary) == noErr {
            print("User removed successfully from the keychain")
        } else {
            print("Something went wrong trying to remove the user from the keychain")
        }
        hasKeychainPassword(has: false)
        finishedLoading()
    }
}
