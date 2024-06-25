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
        let asset = AVAsset(url: URL(string: cameraURL)!)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        HStack {
            if showVideo {
                VideoPlayer(player: player).ignoresSafeArea()
                    .onAppear { player.play() }
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
            let date = Date().timeIntervalSince1970 * 1000
            for daycare in rhizomeSchedule!.daycare {
                let startDate = Double(daycare.date - (60 * 60 * 100))
                let endDate = Double(daycare.pickupDate + (60 * 60 * 100))
                if date  > startDate && date < endDate {
                    showVideo = true
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(cameraURL: "")
}
