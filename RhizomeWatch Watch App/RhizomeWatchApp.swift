//
//  RhizomeWatchApp.swift
//  RhizomeWatch Watch App
//
//  Created by David Jensenius on 2024-08-11.
//

import SwiftUI

@main
struct RhizomeWatchWatchAppApp: App {
    @State private var whereWeAre = WhereWeAre()
    @State var cameraURL = ""
    @State var images: [String] = []
    @State var rhizomeSchedule: Appointments?
    @State var newsUrl: String?

    @State private var user: String?

    var body: some Scene {
        WindowGroup {
            if whereWeAre.loading == true {
                LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
                    .transition(.opacity.animation(.linear))
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name.loginsUpdated)) { object in
                        if ((object.userInfo?["keysComplete"]) != nil) == true {
                            if object.object != nil {
                                let configResponse = object.object! as? LoginResponse
                                cameraURL = configResponse?.cameraURL ?? ""
                                images = configResponse?.rhizomeData.photos ?? []
                                newsUrl = configResponse?.rhizomeData.news ?? nil
                                rhizomeSchedule = configResponse?.rhizomeSchedule.appointments
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
                    ContentView(cameraURL: cameraURL, rhizomeSchedule: rhizomeSchedule)
                        .tabItem {
                            Label("Watch", systemImage: "tv")
                        }
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logout)) { object in
                            if (object.userInfo?["logout"]) != nil {
                                DispatchQueue.main.async { @MainActor in
                                    self.whereWeAre = WhereWeAre()
                                }
                            }
                        }
                }
        }
    }
}
