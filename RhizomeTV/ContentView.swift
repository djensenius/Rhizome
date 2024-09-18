//
//  ContentView.swift
//  RhizomeTV
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var inPlayroom = false
    @State var path = [Int]()

    var showRhizome: some View {
        ZStack {
            VStack {
                if inPlayroom {
                    Text("🐕🎉 Rhizome is playing! 🎉🐕")
                        .padding([.bottom], 20)
                } else {
                    Text("🐕 Rhizome is not in the playroom 🐕")
                        .padding([.bottom], 20)
                }
                Button {
                    path = [1]
                } label: {
                    if inPlayroom {
                        Text("Watch Rhizome")
                    } else {
                        Text("View Anyway")
                    }
                }
            }
        }
    }

    var body: some View {
        let asset = AVURLAsset(url: URL(string: cameraURL)!)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        NavigationStack(path: $path) {
            HStack {
                showRhizome
            }.navigationDestination(for: Int.self) { selection in
                if selection == 1 {
                    VideoPlayer(player: player).ignoresSafeArea()
                        .onAppear { player.play() }
                        .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .onAppear(perform: parseSchedule)
    }

    func parseSchedule() {
        if rhizomeSchedule != nil && rhizomeSchedule?.daycare != nil && rhizomeSchedule?.daycare.count ?? 0 > 0 {
            for daycare in rhizomeSchedule!.daycare {
                let startDate = Date(timeIntervalSince1970: TimeInterval((daycare.date / 1000) - (60 * 60)))
                let endDate = Date(timeIntervalSince1970: TimeInterval((daycare.pickupDate / 1000) + (60 * 60)))
                if Date.now  > startDate && Date.now < endDate {
                    inPlayroom = true
                    path.append(1)
                } else {
                    inPlayroom = false
                }
            }
        }
    }
}

#Preview {
    ContentView(cameraURL: "")
}
