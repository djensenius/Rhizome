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
        VStack(spacing: 60) {
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .cornerRadius(40)
                .shadow(radius: 10)

            Text("🐕 Rhizome 🐕")
                .font(Theme.Fonts.header4XL())
                .foregroundColor(Theme.Colors.textPrimary)
                .bold()
                .padding(.bottom, 40)

            Button("Sign In") {
                controller.start()
            }
            .padding()
            .buttonStyle(.card)
            .padding(.top, 20)
        }
        .padding(50)
        .font(Theme.Fonts.bodyLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SignInContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInContentView().environmentObject(AuthenticationController())
    }
}
