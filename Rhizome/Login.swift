//
//  Login.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import Foundation

struct LoginRequest: Encodable {
    let password: String
}

struct LoginResponse: Decodable {
    let cameraURL: String
}

struct FluxObject {
    let name: String
    let object: LoginResponse
    let userInfo: [String: Bool]
}

class LoginViewModel: ObservableObject {
    @Published var password: String = ""

    func login() {
        LoginAction(
            parameters: LoginRequest(
                password: password
            )
        ).call()
    }
}

struct LoginAction {
    var parameters: LoginRequest

    func call() {
        queryFlux(password: parameters.password)
    }
}
