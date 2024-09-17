//
//  GridView.swift
//  Rhizome
//
//  Created by David Jensenius on 2024-09-17.
//

import SwiftUI

struct GridView: View {
    var images: [String] = []

    private static let initialColumns = 3

    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns

    private var columnsTitle: String {
        gridColumns.count > 1 ? "\(gridColumns.count) Columns" : "1 Column"
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(0..<images.count, id: \.self) { imageIndex in
                        GeometryReader { geo in
                            NavigationLink(destination: DetailView(item: URL(string: images[imageIndex])!)) {
                                GridItemView(size: geo.size.width, item: URL(string: images[imageIndex])!)
                            }
                        }
                        .cornerRadius(8.0)
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                .padding()
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(images: [])
    }
}
