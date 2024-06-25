//
//  ContentView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var showVideo = false
    @State var toolBarStatus: Visibility = .automatic

    var body: some View {
        let asset = AVAsset(url: URL(string: cameraURL)!)

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        HStack {
            if showVideo {
                VideoPlayer(player: player).ignoresSafeArea()
                    .onAppear {
                        player.play()
                        if UIDevice.current.orientation == .landscapeLeft ||
                            UIDevice.current.orientation == .landscapeRight {
                            toolBarStatus = .hidden
                        } else {
                            toolBarStatus = .automatic
                        }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                    ) { _ in
                        if UIDevice.current.orientation == .landscapeLeft ||
                            UIDevice.current.orientation == .landscapeRight {
                            toolBarStatus = .hidden
                        } else {
                            toolBarStatus = .automatic
                        }
                    }
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
        }
        .onAppear(perform: parseSchedule)
        .toolbar(toolBarStatus, for: .tabBar)
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

#Preview {
    ContentView(cameraURL: "")
}
