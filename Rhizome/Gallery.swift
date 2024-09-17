//
//  Gallery.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-06-24.
//

import SwiftUI

struct Gallery: View {
    var images: [String] = []
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                TabView(selection: $currentIndex) {
                    ForEach(0..<images.count, id: \.self) { imageIndex in
                        AsyncImage(
                            url: URL(string: images[imageIndex]),
                            transaction: .init(animation: .easeIn(duration: 0.3))
                        ) { phase in
                            switch phase {
                            case .success(let image):
                                image.framedAspectRatio(contentMode: .fit)
                            default:
                                Image(systemName: "dog.circle")
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaledToFit()
                        /*
                         Image(images[imageIndex])
                         .resizable()
                         .scaledToFill()
                         .frame(height: 200)
                         .cornerRadius(30)
                         .clipped()
                         .tag(imageIndex)
                         */
                    }
                }
                #if !os(macOS)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                #endif
            }
            .onReceive(timer) {_ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % images.count
                }
            }
        }
    }
}

#Preview {
    Gallery()
}

extension View {
    public func framedAspectRatio(_ aspect: CGFloat? = nil, contentMode: ContentMode) -> some View where Self == Image {
        self.resizable()
            .fixedAspectRatio(contentMode: contentMode)
            .allowsHitTesting(false)
    }

    public func fixedAspectRatio(_ aspect: CGFloat? = nil, contentMode: ContentMode) -> some View {
        self.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .aspectRatio(aspect, contentMode: contentMode)
            .clipped()
    }
}
