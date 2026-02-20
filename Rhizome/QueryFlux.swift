//
//  QueryFlux.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import Foundation

func queryFlux(password: String) {
    let scheme: String = "https"
    let host: String = "api.fluxhaus.io"
    let path = "/"

    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.path = path

    guard let url = components.url else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "get"

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let credentialData = Data("rhizome:\(password)".utf8)
    let base64Credential = credentialData.base64EncodedString()
    request.setValue("Basic \(base64Credential)", forHTTPHeaderField: "Authorization")

    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request) { @Sendable data, response, error in
        let httpResponse = response as? HTTPURLResponse
        if httpResponse?.statusCode == 401 {
            DispatchQueue.main.async { @MainActor in
                NotificationCenter.default.post(
                    name: Notification.Name.loginsUpdated,
                    object: nil,
                    userInfo: ["loginError": "Incorrect Password"]
                )
            }
            return
        }
        handleQueryFluxResponse(data: data, error: error, password: password)
    }
    task.resume()
}

func handleQueryFluxResponse(data: Data?, error: Error?, password: String) {
    if let error = error {
        DispatchQueue.main.async { @MainActor in
            NotificationCenter.default.post(
                name: Notification.Name.loginsUpdated,
                object: nil,
                userInfo: ["loginError": error.localizedDescription]
            )
        }
        return
    }

    if let data = data {
        let response = try? JSONDecoder().decode(LoginResponse.self, from: data)

        if let response = response {
            DispatchQueue.main.async { @MainActor in
                NotificationCenter.default.post(
                    name: Notification.Name.loginsUpdated,
                    object: response,
                    userInfo: ["keysComplete": true]
                )

                NotificationCenter.default.post(
                    name: Notification.Name.loginsUpdated,
                    object: nil,
                    userInfo: ["updateKeychain": password]
                )
            }
        } else {
            // Error: Unable to decode response JSON
            // This also happens if the password is wrong!
            DispatchQueue.main.async { @MainActor in
                NotificationCenter.default.post(
                    name: Notification.Name.loginsUpdated,
                    object: nil,
                    userInfo: ["loginError": "Incorrect Password"]
                )
            }
        }
    }
}
