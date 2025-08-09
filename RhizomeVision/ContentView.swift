//
//  ContentView.swift
//  RhizomeVision
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit
import RealityKit
import RealityKitContent

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var showVideo = false

    var body: some View {
        HStack {
            if showVideo {
                VideoPlayerView(cameraURL: cameraURL)
            } else {
                VStack {
                    Text("🐕 Rhizome is not in the playroom 🐕")
                        .padding([.bottom], 20)
                    Button {
                        showVideo = true
                    } label: {
                        Text("View Anyway")
                    }
                }
            }
        }.onAppear(perform: parseSchedule)
    }

    func parseSchedule() {
        if rhizomeSchedule != nil && rhizomeSchedule?.daycare != nil && rhizomeSchedule?.daycare.count ?? 0 > 0 {
            for daycare in rhizomeSchedule!.daycare {
                let startDate = Date(timeIntervalSince1970: TimeInterval((daycare.date / 1000) - (60 * 60)))
                let endDate = Date(timeIntervalSince1970: TimeInterval((daycare.pickupDate / 1000) + (60 * 60)))
                if Date.now  > startDate && Date.now < endDate {
                    showVideo = true
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(cameraURL: "")
}
