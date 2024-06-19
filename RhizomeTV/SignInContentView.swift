//
//  SignInContentView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

/// A view that displays the main sign-in content.
struct SignInContentView: View {
    @EnvironmentObject private var controller: AuthenticationController

    var body: some View {
        VStack(spacing: 48) {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
            Text("🐕 Rhizome 🐕")
                .font(.system(.largeTitle))
                .bold()

            Button("Sign In") {
                controller.start()
            }
        }
        .font(.system(.headline))
    }
}

struct SignInContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInContentView().environmentObject(AuthenticationController())
    }
}

