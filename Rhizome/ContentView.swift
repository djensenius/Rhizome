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
    var body: some View {
        let asset = AVAsset(url: URL(string: cameraURL)!)

        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        VideoPlayer(player: player).ignoresSafeArea()
            .onAppear { player.play() }
    }
}

#Preview {
    ContentView(cameraURL: "")
}
