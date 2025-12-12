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
#if canImport(AVFoundation)
import AVFoundation
#endif

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

#if os(iOS) || os(tvOS) || os(visionOS)
struct PlayerViewController: UIViewControllerRepresentable {
    var player: AVPlayer?

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
    }
}
#endif

struct VideoPlayerView: View {
    let cameraURL: String?
    let existingPlayer: AVPlayer?
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @StateObject private var playerObserver = PlayerObserver()

    // Initializer for URL-based player (current behavior)
    init(cameraURL: String, onDismiss: (() -> Void)? = nil) {
        self.cameraURL = cameraURL
        self.existingPlayer = nil
        self.onDismiss = onDismiss
    }

    // Initializer for existing player (replaces AZVideoPlayer)
    init(player: AVPlayer, onDismiss: (() -> Void)? = nil) {
        self.cameraURL = nil
        self.existingPlayer = player
        self.onDismiss = onDismiss
    }

    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                #if os(iOS) || os(tvOS) || os(visionOS)
                PlayerViewController(player: player)
                #else
                VideoPlayer(player: player)
                #endif
            }
            .ignoresSafeArea()

            #if os(iOS) || os(visionOS)
            Button(action: {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            })
            .padding(.leading, 16)
            .padding(.top, 48)
            .zIndex(1)
            #endif

            #if os(macOS)
            Button(action: {
                NSApp.keyWindow?.toggleFullScreen(nil)
            }, label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            })
            .padding(.trailing, 16)
            .padding(.top, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .zIndex(1)
            #endif
        }
            .ignoresSafeArea()
            .onAppear {
                setupPlayer()
                configureAudioAndScreen()
            }
            .onDisappear {
                cleanupPlayer()
                restoreAudioAndScreen()
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

    private func configureAudioAndScreen() {
        #if os(iOS) || os(tvOS) || os(visionOS)
        // Play audio even in silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        #endif

        #if os(iOS)
        // Keep screen awake
        UIApplication.shared.isIdleTimerDisabled = true
        #endif
    }

    private func restoreAudioAndScreen() {
        #if os(iOS)
        // Allow screen to sleep
        UIApplication.shared.isIdleTimerDisabled = false
        #endif
    }
}
