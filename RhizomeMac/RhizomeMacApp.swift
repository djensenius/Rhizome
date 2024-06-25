//
//  RhizomeMacApp.swift
//  RhizomeMac
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

@main
struct RhizomeMacApp: App {
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
                ContentView(cameraURL: cameraURL, rhizomeSchedule: rhizomeSchedule)
            }
        }
    }
}

/* For next version of OSes
 TabView {
     Tab("Watch Now", systemImage: "play") {
         // ...
     }
     Tab("Library", systemImage: "books.vertical") {
         // ...
     }
     // ...
     TabSection("Collections") {
         Tab("Cinematic Shots", systemImage: "list.and.film") {
             // ...
         }
         Tab("Forest Life", systemImage: "list.and.film") {
             // ...
         }
         // ...
     }
     TabSection("Animations") {
         // ...
     }
     Tab(role: .search) {
         // ...
     }
 }
 .tabViewStyle(.sidebarAdaptable)
 */
