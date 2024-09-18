//
//  ContentView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit
import AZVideoPlayer

struct ContentView: View {
    var cameraURL: String
    var rhizomeSchedule: Appointments?
    @State var showVideo = false
    @State var toolBarStatus: Visibility = .automatic
    @State var safeAreas: Edge.Set = .all
    @State var willBeginFullScreenPresentation: Bool = false
    @State var inPlayroom = false
    @State var path = [Int]()
    var player: AVPlayer?

    init(cameraURL: String, rhizomeSchedule: Appointments?) {
        self.cameraURL = cameraURL
            self.player = AVPlayer(url: URL(string: cameraURL)!)
        self.rhizomeSchedule = rhizomeSchedule
    }

    var showRhizome: some View {
        HStack {
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
        NavigationStack(path: $path) {
            HStack {
                showRhizome
            }.navigationDestination(for: Int.self) { selection in
                if selection == 1 {
                    HStack {
                        AZVideoPlayer(
                            player: player,
                            willBeginFullScreenPresentationWithAnimationCoordinator: willBeginFullScreen,
                            willEndFullScreenPresentationWithAnimationCoordinator: willEndFullScreen,
                            statusDidChange: statusDidChange,
                            showsPlaybackControls: true,
                            entersFullScreenWhenPlaybackBegins: false,
                            pausesWhenFullScreenPlaybackEnds: false
                        ).ignoresSafeArea(edges: safeAreas)
                            .onAppear {
                                player?.play()
                                toolBarStatus = .automatic
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    safeAreas = [.top]
                                }
                            }
                            .onDisappear {
                                guard !willBeginFullScreenPresentation else {
                                    willBeginFullScreenPresentation = false
                                    return
                                }
                                player?.pause()
                            }
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

    func willBeginFullScreen(_ playerViewController: AVPlayerViewController,
                             _ coordinator: UIViewControllerTransitionCoordinator) {
        willBeginFullScreenPresentation = true
    }

    func willEndFullScreen(_ playerViewController: AVPlayerViewController,
                           _ coordinator: UIViewControllerTransitionCoordinator) {
    }

    func statusDidChange(_ status: AZVideoPlayerStatus) {
        print(status.timeControlStatus.rawValue)
        print(status.volume)
    }
}
