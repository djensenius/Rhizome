//
//  GidItemView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-09-17.
//

import SwiftUI

struct GridItemView: View {
    let size: Double
    let item: URL

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: item) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: size, height: size)
        }
    }
}

struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            GridItemView(size: 50, item: url)
        }
    }
}
