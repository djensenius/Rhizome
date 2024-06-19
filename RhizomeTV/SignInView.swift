//
//  SignInView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import Combine
import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    @StateObject private var controller = AuthenticationController()
    @State var loggedIn: Bool = false

    /// A binding that stores an authenticated user.
    var user: Binding<String?>
    var needLoginView: Bool
    
    private var wantsManualPasswordAuthentication: Binding<Bool> {
        Binding(
            get: { controller.state.wantsManualPasswordAuthentication },
            set: { _ in controller.state.reset() }
        )
    }

    private var authenticationError: Binding<AuthenticationError?> {
        Binding(
            get: { controller.state.error },
            set: { _ in controller.state.reset() }
        )
    }
    
    var body: some View {
        if needLoginView && !loggedIn {
            SignInContentView()
                .sheet(isPresented: wantsManualPasswordAuthentication) {
                    PasswordSignInView()
                }
                .alert(item: authenticationError) {
                    Alert(
                        title: Text("Sign In Failed"),
                        message: Text($0.localizedDescription),
                        dismissButton: .cancel(Text("OK"))
                    )
                }
                .onReceive(controller.userAuthenticatedPublisher) {
                    user.wrappedValue = $0
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.loginsUpdated)) { object in
                    if (object.userInfo?["loginError"]) != nil {
                        print("Login error")
                    }
                    if (object.userInfo?["keysComplete"]) != nil {
                        print("Logged in")
                    }
                }
                .environmentObject(controller)
        } else {
            Image(systemName: "dog.circle")
        }
    }
}

private extension AuthenticationController {
    /// A publisher that sends an authenticated user when one exists then completes.
    var userAuthenticatedPublisher: AnyPublisher<String, Never> {
        $state.flatMap { state -> AnyPublisher<String, Never> in
            if let user = state.user {
                return Just(user).eraseToAnyPublisher()
            }
            return Empty<String, Never>(completeImmediately: false).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
