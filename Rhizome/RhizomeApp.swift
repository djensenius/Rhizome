//
//  RhizomeApp.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

@main
struct RhizomeApp: App {
    @State private var whereWeAre = WhereWeAre()
    @State var cameraURL = ""
    @State var images: [String] = []
    @State var rhizomeSchedule: Appointments?
    @State var newsUrl: String?

    var body: some Scene {
        WindowGroup {
            if whereWeAre.loading == true {
                LoadingView(needLoginView: !whereWeAre.hasKeyChainPassword)
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
                TabView {
                    ContentView(cameraURL: cameraURL, rhizomeSchedule: rhizomeSchedule)
                        .tabItem {
                            Label("Watch", systemImage: "tv")
                        }
                    Schedule(newsUrl: newsUrl, schedule: rhizomeSchedule)
                        .tabItem {
                            Label("Schedule", systemImage: "calendar")
                        }
                    Gallery(images: images)
                        .tabItem {
                            Label("Gallery", systemImage: "photo")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logout)) { object in
                    if (object.userInfo?["logout"]) != nil {
                        DispatchQueue.main.async { @MainActor in
                            self.whereWeAre = WhereWeAre()
                        }
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
            }
        }
    }
}
