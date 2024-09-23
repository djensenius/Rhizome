//
//  RhizomeTabs.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-09-18.
//

import SwiftUI

struct RhizomeTabs: View {
    var cameraUrl: String
    var rhizomeSchedule: Appointments
    var newsUrl: String
    var images: [String]

    @State private var selectedTab = "0"
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Watch", systemImage: "tv", value: "0") {
                ContentView(cameraURL: cameraUrl, rhizomeSchedule: rhizomeSchedule)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .customizationID("0")

            Tab("Schedule", systemImage: "calendar", value: "1") {
                Schedule(newsUrl: newsUrl, schedule: rhizomeSchedule)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .customizationID("1")

            Tab("Images", systemImage: "photo", value: "2") {
                Gallery(images: images)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .customizationID("2")

            Tab("Settings", systemImage: "gear", value: "3") {
                SettingsView()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
            .customizationID("3")
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
