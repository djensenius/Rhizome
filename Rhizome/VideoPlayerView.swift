//
//  VideoPlayerView.swift
//  Rhizome
//
//  Created by David Jensenius on 2025-01-11.
//
// swiftlint:disable file_length

import Foundation
import AVKit
import Combine
import SwiftUI
import Photos
import QuartzCore
#if canImport(AVFoundation)
import AVFoundation
#endif
#if os(macOS)
import AppKit
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
    let cameras: [CameraFeed]
    let existingPlayer: AVPlayer?

    @State private var activeCameraURL: String
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @StateObject private var playerObserver = PlayerObserver()
    @State private var videoOutput: AVPlayerItemVideoOutput?

    // Recording state
    @State private var isRecording = false
    @State private var assetWriter: AVAssetWriter?
    @State private var assetWriterInput: AVAssetWriterInput?
    @State private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    @State private var recordingTimer: Timer?
    @State private var recordingStartTime: CMTime = .invalid
    @State private var recordingOutputURL: URL?

    // UI feedback
    @State private var showSaveSuccess = false
    @State private var showSaveError = false

    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)?

    init(cameras: [CameraFeed], onDismiss: (() -> Void)? = nil) {
        self.cameras = cameras
        self.existingPlayer = nil
        self.onDismiss = onDismiss
        self._activeCameraURL = State(initialValue: cameras.first?.url ?? "")
    }

    init(cameraURL: String, onDismiss: (() -> Void)? = nil) {
        self.cameras = [CameraFeed(id: "default", name: "Camera", url: cameraURL)]
        self.existingPlayer = nil
        self.onDismiss = onDismiss
        self._activeCameraURL = State(initialValue: cameraURL)
    }

    init(player: AVPlayer, onDismiss: (() -> Void)? = nil) {
        self.cameras = []
        self.existingPlayer = player
        self.onDismiss = onDismiss
        self._activeCameraURL = State(initialValue: "")
    }

    var body: some View {
        ZStack {
            Group {
                #if os(iOS) || os(tvOS) || os(visionOS)
                PlayerViewController(player: player)
                #else
                VideoPlayer(player: player)
                #endif
            }
            #if os(iOS) || os(tvOS) || os(visionOS)
            .ignoresSafeArea()
            #endif

            overlayControls
        }
        #if os(iOS) || os(tvOS) || os(visionOS)
        .ignoresSafeArea()
        #endif
        #if os(tvOS)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .onAppear {
            setupPlayer()
            configureAudioAndScreen()
        }
        .onDisappear {
            if isRecording { stopRecording() }
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
        .alert("Saved!", isPresented: $showSaveSuccess) {
            Button("OK") {}
        } message: {
            Text("Saved to your photo library.")
        }
        .alert("Save Failed", isPresented: $showSaveError) {
            Button("OK") {}
        } message: {
            Text("Could not save to photo library. Please check permissions in Settings.")
        }
    }

    // MARK: - Overlay Controls

    @ViewBuilder
    private var overlayControls: some View {
        #if os(iOS) || os(visionOS)
        VStack(spacing: 0) {
            HStack(alignment: .top) {
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

                Spacer()

                HStack(spacing: 12) {
                    Button(action: takeScreenshot) {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(
                        action: { isRecording ? stopRecording() : startRecording() },
                        label: {
                            Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                                .font(.title3)
                                .foregroundColor(isRecording ? .red : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    )
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 48)

            Spacer()

            if cameras.count > 1 {
                cameraSwitcher
                    .padding(.bottom, 40)
            }
        }
        .zIndex(1)
        #elseif os(macOS)
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Spacer()
                HStack(spacing: 10) {
                    Button(action: takeScreenshot) {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button(
                        action: { isRecording ? stopRecording() : startRecording() },
                        label: {
                            Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                                .font(.title3)
                                .foregroundColor(isRecording ? .red : .white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    )
                    .buttonStyle(.plain)

                    Button(action: {
                        NSApplication.shared.windows.first?.toggleFullScreen(nil)
                    }, label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    })
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 16)
                .padding(.top, 16)
            }

            Spacer()

            if cameras.count > 1 {
                cameraSwitcher
                    .padding(.bottom, 20)
            }
        }
        .zIndex(100)
        #elseif os(tvOS)
        if cameras.count > 1 {
            VStack {
                Spacer()
                cameraSwitcher
                    .padding(.bottom, 60)
            }
            .zIndex(1)
        }
        #endif
    }

    @ViewBuilder
    private var cameraSwitcher: some View {
        HStack(spacing: 10) {
            ForEach(cameras) { camera in
                Button(camera.name) {
                    if camera.url != activeCameraURL {
                        switchCamera(to: camera)
                    }
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    camera.url == activeCameraURL
                        ? Color.white.opacity(0.9)
                        : Color.black.opacity(0.5)
                )
                .foregroundColor(camera.url == activeCameraURL ? .black : .white)
                .clipShape(Capsule())
                #if os(macOS) || os(tvOS)
                .buttonStyle(.plain)
                #endif
            }
        }
    }
}

// MARK: - Player Management
private extension VideoPlayerView {
    func setupPlayer() {
        if let existingPlayer = existingPlayer {
            player = existingPlayer
            player?.play()
        } else if let url = URL(string: activeCameraURL) {
            let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ])
            let asset = AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            playerItem?.add(output)
            videoOutput = output
            player = AVPlayer(playerItem: playerItem)
            player?.play()

            if let playerItem = playerItem {
                playerObserver.observe(playerItem: playerItem)
            }
        }
    }

    func cleanupPlayer() {
        if existingPlayer == nil {
            player?.pause()
            playerObserver.stopObserving()
            if let output = videoOutput, let item = playerItem {
                item.remove(output)
            }
            videoOutput = nil
            player = nil
            playerItem = nil
        }
    }

    func switchCamera(to camera: CameraFeed) {
        if isRecording { stopRecording() }
        cleanupPlayer()
        activeCameraURL = camera.url
        setupPlayer()
        configureAudioAndScreen()
    }

    func configureAudioAndScreen() {
        #if os(iOS) || os(tvOS) || os(visionOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        #endif

        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = true
        #endif
    }

    func restoreAudioAndScreen() {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = false
        #endif
    }

}

// MARK: - Screenshot & Recording
private extension VideoPlayerView {
    func takeScreenshot() {
        guard let output = videoOutput else { return }
        let hostTime = CACurrentMediaTime()
        let itemTime = output.itemTime(forHostTime: hostTime)
        guard output.hasNewPixelBuffer(forItemTime: itemTime),
              let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)
        else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        #if os(iOS) || os(visionOS)
        let image = UIImage(cgImage: cgImage)
        saveImageToPhotos(image)
        #elseif os(macOS)
        let image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        saveImageToPhotos(image)
        #endif
    }

    func startRecording() {
        guard let playerItem = playerItem, let output = videoOutput else { return }

        let size = playerItem.presentationSize
        let width = size.width > 0 ? Int(size.width) : 1920
        let height = size.height > 0 ? Int(size.height) : 1080

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("rhizome_\(Int(Date().timeIntervalSince1970)).mp4")

        guard let writer = try? AVAssetWriter(outputURL: tempURL, fileType: .mp4) else { return }

        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = true

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )

        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        assetWriter = writer
        assetWriterInput = input
        pixelBufferAdaptor = adaptor
        recordingStartTime = .invalid
        recordingOutputURL = tempURL
        isRecording = true

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            Task { @MainActor in
                self.captureRecordingFrame(output: output)
            }
        }
    }

    func captureRecordingFrame(output: AVPlayerItemVideoOutput) {
        guard let writer = assetWriter,
              let input = assetWriterInput,
              let adaptor = pixelBufferAdaptor,
              writer.status == .writing,
              input.isReadyForMoreMediaData else { return }

        let hostTime = CACurrentMediaTime()
        let itemTime = output.itemTime(forHostTime: hostTime)

        guard output.hasNewPixelBuffer(forItemTime: itemTime),
              let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)
        else { return }

        if recordingStartTime == .invalid {
            recordingStartTime = itemTime
        }
        let presentationTime = CMTimeSubtract(itemTime, recordingStartTime)
        adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }

    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false

        assetWriterInput?.markAsFinished()
        let writer = assetWriter
        let url = recordingOutputURL
        assetWriter = nil
        assetWriterInput = nil
        pixelBufferAdaptor = nil
        recordingOutputURL = nil
        recordingStartTime = .invalid

        writer?.finishWriting {
            guard let url = url else { return }
            Task { @MainActor in
                self.saveVideoToPhotos(url: url)
            }
        }
    }

}

// MARK: - Photos Saving
private extension VideoPlayerView {
    #if os(iOS) || os(macOS) || os(visionOS)
    func saveImageToPhotos(_ image: PHCompatibleImage) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in self.showSaveError = true }
                return
            }
            PHPhotoLibrary.shared().performChanges(
                { PHAssetChangeRequest.creationRequestForAsset(from: image) },
                completionHandler: { success, _ in
                    Task { @MainActor in
                        if success { self.showSaveSuccess = true } else { self.showSaveError = true }
                    }
                }
            )
        }
    }

    func saveVideoToPhotos(url: URL) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                Task { @MainActor in self.showSaveError = true }
                return
            }
            PHPhotoLibrary.shared().performChanges(
                { PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) },
                completionHandler: { success, _ in
                    Task { @MainActor in
                        try? FileManager.default.removeItem(at: url)
                        if success { self.showSaveSuccess = true } else { self.showSaveError = true }
                    }
                }
            )
        }
    }
    #else
    func saveVideoToPhotos(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    #endif
}

// Platform-unified image type for PHAssetChangeRequest.creationRequestForAsset(from:)
#if os(iOS) || os(visionOS)
typealias PHCompatibleImage = UIImage
#elseif os(macOS)
typealias PHCompatibleImage = NSImage
#endif
