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
    @Published var isBuffering = false
    @Published var needsRetry = false

    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var statusObservation: NSKeyValueObservation?
    private var errorObservation: NSKeyValueObservation?
    private var timeControlObservation: NSKeyValueObservation?
    private var bufferObservation: NSKeyValueObservation?
    private var stalledObserver: Any?
    private var failedObserver: Any?

    func observe(player: AVPlayer, playerItem: AVPlayerItem) {
        self.player = player
        self.playerItem = playerItem
        observeItemStatus(playerItem)
        observeBuffering(playerItem)
        observeTimeControl(player)
        observeNotifications(playerItem)
    }

    // MARK: Private helpers

    private func observeItemStatus(_ item: AVPlayerItem) {
        statusObservation = item.observe(\.status, options: [.new, .initial]) { [weak self] obs, _ in
            Task { @MainActor in
                if obs.status == .failed, let error = obs.error {
                    self?.playerError = PlayerError(error: error)
                    self?.needsRetry = true
                }
            }
        }
    }

    private func observeBuffering(_ item: AVPlayerItem) {
        bufferObservation = item.observe(
            \.isPlaybackLikelyToKeepUp,
             options: [.new, .initial]
        ) { [weak self] obs, _ in
            Task { @MainActor in
                if !obs.isPlaybackLikelyToKeepUp { self?.isBuffering = true }
            }
        }
    }

    private func observeTimeControl(_ avPlayer: AVPlayer) {
        timeControlObservation = avPlayer.observe(
            \.timeControlStatus,
             options: [.new, .initial]
        ) { [weak self] obs, _ in
            Task { @MainActor in
                switch obs.timeControlStatus {
                case .playing:
                    self?.isBuffering = false
                    self?.needsRetry = false
                case .waitingToPlayAtSpecifiedRate:
                    self?.isBuffering = true
                case .paused:
                    self?.isBuffering = true
                @unknown default:
                    break
                }
            }
        }
    }

    private func observeNotifications(_ item: AVPlayerItem) {
        stalledObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.playbackStalledNotification,
            object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.isBuffering = true; self?.needsRetry = true }
        }

        failedObserver = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.failedToPlayToEndTimeNotification,
            object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.needsRetry = true }
        }
    }

    func stopObserving() {
        statusObservation?.invalidate()
        bufferObservation?.invalidate()
        timeControlObservation?.invalidate()
        if let stalledObserver { NotificationCenter.default.removeObserver(stalledObserver) }
        if let failedObserver { NotificationCenter.default.removeObserver(failedObserver) }
        stalledObserver = nil
        failedObserver = nil
        player = nil
        playerItem = nil
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
#elseif os(macOS)
struct PlayerNSView: NSViewRepresentable {
    var player: AVPlayer?

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player != player {
            nsView.player = player
        }
    }
}
#endif

// swiftlint:disable type_body_length
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

    // Buffering / reconnect
    @State private var retryTask: Task<Void, Never>?

    // Controls visibility
    @State private var showControls = true
    @State private var hideTask: Task<Void, Never>?

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
                #elseif os(macOS)
                PlayerNSView(player: player)
                    .ignoresSafeArea()
                #endif
            }
            #if os(iOS) || os(tvOS) || os(visionOS)
            .ignoresSafeArea()
            #endif

            // Buffering indicator
            if playerObserver.isBuffering {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(.white)
                    .padding(20)
                    .background(Color.black.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            overlayControls
        }
        #if os(iOS) || os(tvOS) || os(visionOS)
        .ignoresSafeArea()
        #endif
        #if os(iOS) || os(visionOS)
        .simultaneousGesture(TapGesture().onEnded { toggleControls() })
        #elseif os(macOS)
        .onContinuousHover { phase in
            switch phase {
            case .active:
                withAnimation(.easeInOut(duration: 0.25)) { showControls = true }
                scheduleHide()
            case .ended:
                scheduleHide()
            }
        }
        #elseif os(tvOS)
        .simultaneousGesture(TapGesture().onEnded { toggleControls() })
        #endif
        #if os(tvOS)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .onAppear {
            setupPlayer()
            configureAudioAndScreen()
            scheduleHide()
            startRetryLoop()
        }
        .onDisappear {
            if isRecording { stopRecording() }
            cleanupPlayer()
            restoreAudioAndScreen()
            hideTask?.cancel()
            retryTask?.cancel()
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
        .opacity(showControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: showControls)
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
        .opacity(showControls ? 1 : 0)
        .animation(.easeInOut(duration: 0.25), value: showControls)
        .zIndex(100)
        #elseif os(tvOS)
        if cameras.count > 1 {
            VStack {
                Spacer()
                cameraSwitcher
                    .padding(.bottom, 60)
            }
            .opacity(showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: showControls)
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
// swiftlint:enable type_body_length

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
            let item = AVPlayerItem(asset: asset)
            item.add(output)
            playerItem = item
            videoOutput = output
            let newPlayer = AVPlayer(playerItem: item)
            player = newPlayer
            player?.play()
            playerObserver.observe(player: newPlayer, playerItem: item)
        }
    }

    func reconnectPlayer() {
        guard existingPlayer == nil else { return }
        if isRecording { stopRecording() }
        playerObserver.stopObserving()
        player?.pause()
        if let output = videoOutput, let item = playerItem { item.remove(output) }
        videoOutput = nil
        player = nil
        playerItem = nil
        setupPlayer()
        configureAudioAndScreen()
    }

    func startRetryLoop() {
        guard existingPlayer == nil else { return }
        retryTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                if playerObserver.needsRetry {
                    reconnectPlayer()
                }
            }
        }
    }

    func cleanupPlayer() {
        if existingPlayer == nil {
            player?.pause()
            playerObserver.stopObserving()
            if let output = videoOutput, let item = playerItem { item.remove(output) }
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

    func scheduleHide() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) { showControls = false }
        }
    }

    func toggleControls() {
        withAnimation(.easeInOut(duration: 0.25)) { showControls.toggle() }
        if showControls {
            scheduleHide()
        } else {
            hideTask?.cancel()
        }
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
