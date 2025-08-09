//
//  VideoPlayerView.swift
//  Rhizome
//
//  Created by David Jensenius on 2025-01-11.
//

import Foundation
import AVKit
import Combine
import SwiftUI

struct PlayerError: Identifiable {
    let id = UUID()
    let error: Error
}

@MainActor
class PlayerObserver: NSObject, ObservableObject {
    @Published var playerError: PlayerError?
    private var playerItem: AVPlayerItem?
    private var statusObservation: NSKeyValueObservation?
    private var errorObservation: NSKeyValueObservation?

    func observe(playerItem: AVPlayerItem) {
        self.playerItem = playerItem
        statusObservation = playerItem.observe(\.status, options: [.new, .initial]) { [weak self] item, _ in
            if item.status == .failed {
                if let error = item.error {
                    Task { @MainActor in
                        self?.playerError = PlayerError(error: error)
                    }
                }
            }
        }

        errorObservation = playerItem.observe(\.error, options: [.new, .initial]) { [weak self] item, _ in
            if let error = item.error {
                Task { @MainActor in
                    self?.playerError = PlayerError(error: error)
                }
            }
        }
    }

    func stopObserving() {
        statusObservation?.invalidate()
        errorObservation?.invalidate()
    }
}
struct VideoPlayerView: View {
    let cameraURL: String
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @StateObject private var playerObserver = PlayerObserver()

    var body: some View {
        if let url = URL(string: cameraURL) {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear {
                    setupPlayer(url: url)
                }
                .onDisappear {
                    cleanupPlayer()
                }
                .alert(item: $playerObserver.playerError) { playerError in
                    Alert(
                        title: Text("Playback Error"),
                        message: Text(playerError.error.localizedDescription),
                        dismissButton: .default(Text("OK"))
                    )
                }
        } else {
            Text("Invalid URL")
        }
    }

    private func setupPlayer(url: URL) {
        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        player?.play()

        // Observe AVPlayerItem status and error using block-based KVO
        if let playerItem = playerItem {
            playerObserver.observe(playerItem: playerItem)
        }
    }

    private func cleanupPlayer() {
        player?.pause()
        playerObserver.stopObserving()
        player = nil
        playerItem = nil
    }
}
