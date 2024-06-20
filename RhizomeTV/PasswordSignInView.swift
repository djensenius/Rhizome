//
//  PasswordSignInView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

struct PasswordSignInView: View {
    @EnvironmentObject private var controller: AuthenticationController
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 48) {
            Text("🐕 Rhizome 🐕")
                .font(.system(.largeTitle))
                .bold()

            VStack(spacing: 16) {
                SecureField("Password", text: $password)
                    .frame(width: 800)
            }

            Button("Sign In") {
                controller.signIn(email: "rhizome", password: password)
            }
            .disabled(password.isEmpty)
        }
        .font(.system(.headline))
    }
}

#Preview {
    PasswordSignInView()
}
