//
//  SettingsView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-08-16.
//

import SwiftUI

struct SettingsView: View {
    @State private var whereWeAre = WhereWeAre()
    var body: some View {
        Button {
            whereWeAre.deleteKeyChainPasword()
            NotificationCenter.default.post(
                name: Notification.Name.logout,
                object: nil,
                userInfo: ["logout": true]
            )
        } label: {
            Text("Logout")
        }
    }
}

#Preview {
    SettingsView()
}
