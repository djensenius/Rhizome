//
//  RhizomeVisionApp.swift
//  RhizomeVision
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

@main
struct RhizomeVisionApp: App {
    @State private var whereWeAre = WhereWeAre()
    @State var cameraURL = ""

    var body: some Scene {
        WindowGroup {
            if whereWeAre.loading == true {
                LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.loginsUpdated)) { object in
                        if ((object.userInfo?["keysComplete"]) != nil) == true {
                            if object.object != nil {
                                let configResponse = object.object! as? LoginResponse
                                cameraURL = configResponse?.cameraURL ?? ""
                            }
                        }

                        if (object.userInfo?["updateKeychain"]) != nil {
                            whereWeAre.setPassword(password: object.userInfo!["updateKeychain"] as? String ?? "")
                        }

                        if ((object.userInfo?["keysFailed"]) != nil) == true {
                            whereWeAre.deleteKeyChainPasword()
                        }
                }
            } else {
                ContentView(cameraURL: cameraURL)
            }
        }
    }
}
