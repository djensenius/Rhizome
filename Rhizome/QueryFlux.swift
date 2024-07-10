//
//  QueryFlux.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import Foundation

func queryFlux(password: String, method: String = "get", body: [String: TimeInterval]? = nil) {
    let scheme: String = "http"
    let host: String = "localhost"
    let port: Int = 8080
    var path = "/"

    if body != nil {
        path = "/scheduleRhizome"
    }

    var components = URLComponents()
    components.scheme = scheme
    components.host = host
    components.path = path
    components.user = "rhizome"
    components.password = password
    components.port = port

    guard let url = components.url else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = method

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    if body != nil {
        let requestBody = try? JSONSerialization.data(withJSONObject: body!)
        request.httpBody = requestBody
    }

    let task = URLSession.shared.dataTask(with: request) { data, _, _ in
        if let data = data {
            let response = try? JSONDecoder().decode(LoginResponse.self, from: data)

            if let response = response {
                if body != nil {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: Notification.Name.scheduledDaycare,
                            object: response,
                            userInfo: ["keysComplete": true]
                        )
                    }
                } else {
                    DispatchQueue.main.async {
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
                        UserDefaults.standard.set(components.user, forKey: "login")
                    }
                }
            } else {
                // Error: Unable to decode response JSON
                // This also happens if the password is wrong!
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name.loginsUpdated,
                        object: nil,
                        userInfo: ["loginError": "Incorrect Password"]
                    )
                }
            }
        }
    }
    task.resume()
}
