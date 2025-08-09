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
    let cameraURL: String?
    let existingPlayer: AVPlayer?
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @StateObject private var playerObserver = PlayerObserver()

    // Initializer for URL-based player (current behavior)
    init(cameraURL: String) {
        self.cameraURL = cameraURL
        self.existingPlayer = nil
    }
    
    // Initializer for existing player (replaces AZVideoPlayer)
    init(player: AVPlayer) {
        self.cameraURL = nil
        self.existingPlayer = player
    }

    var body: some View {
        VideoPlayer(player: player)
            .ignoresSafeArea()
            .onAppear {
                setupPlayer()
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
    }

    private func setupPlayer() {
        if let existingPlayer = existingPlayer {
            // Use existing player (replaces AZVideoPlayer functionality)
            player = existingPlayer
            player?.play()
        } else if let cameraURL = cameraURL, let url = URL(string: cameraURL) {
            // Create new player from URL (current VideoPlayerView behavior)
            let asset = AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            player?.play()

            // Observe AVPlayerItem status and error using block-based KVO
            if let playerItem = playerItem {
                playerObserver.observe(playerItem: playerItem)
            }
        }
    }

    private func cleanupPlayer() {
        // Only pause and cleanup if we created the player ourselves
        if existingPlayer == nil {
            player?.pause()
            playerObserver.stopObserving()
            player = nil
            playerItem = nil
        }
    }
