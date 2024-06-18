//
//  ContentView.swift
//  RhizomeMac
//
//  Created by David Jensenius on 2024-06-18.
//

import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        let asset = AVAsset(url: URL(string: "https://stream-uc2-delta.dropcam.com/nexus_aac/94cabc14ffc2409f86662a9f7bd9ca5a/playlist.m3u8?public=EDvH1b9kI6")!)
        
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        VideoPlayer(player: player).ignoresSafeArea()
            .onAppear { player.play() }
    }
}

#Preview {
    ContentView()
}
