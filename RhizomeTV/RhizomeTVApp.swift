//
//  RhizomeTVApp.swift
//  RhizomeTV
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI

@main
struct RhizomeTVApp: App {
    @State private var whereWeAre = WhereWeAre()
    @State var cameraURL = ""
    @State var images: [String] = []
    @State var rhizomeSchedule: Appointments?
    @State var newsUrl: String?

    @State private var user: String?

    var body: some Scene {
        WindowGroup {
            if whereWeAre.loading == true {
                SignInView(user: $user, needLoginView: !whereWeAre.hasKeyChainPassword)
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
                RhizomeTabs(
                    cameraUrl: cameraURL,
                    rhizomeSchedule: rhizomeSchedule!,
                    newsUrl: newsUrl!,
                    images: images
                )
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.logout)) { object in
                    if (object.userInfo?["logout"]) != nil {
                        DispatchQueue.main.async {
                            self.whereWeAre = WhereWeAre()
                        }
                    }
                }
            }
        }
    }
}
