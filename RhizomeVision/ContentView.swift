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
    var body: some View {
        let asset = AVAsset(url: URL(string: cameraURL)!)
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        VideoPlayer(player: player).ignoresSafeArea()
            .onAppear { player.play() }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(cameraURL: "")
}
