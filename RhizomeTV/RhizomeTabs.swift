//
//  RhizomeTabs.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-09-18.
//

import SwiftUI

struct RhizomeTabs: View {
    var body: some View {
        TabView {
            Tab("Watch", systemImage: "tv") {
                ContentView(cameraURL: "https://stream-uc2-delta.dropcam.com/nexus_aac/94cabc14ffc2409f86662a9f7bd9ca5a/playlist.m3u8?public=EDvH1b9kI6", rhizomeSchedule: nil)
            }
            /*
            Schedule(newsUrl: newsUrl, schedule: rhizomeSchedule)
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            Gallery(images: images)
                .tabItem {
                    Label("Gallery", systemImage: "photo")
                }
             */
            Tab("Settings", systemImage: "gear") {
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    RhizomeTabs()
}
