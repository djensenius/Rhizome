import SwiftUI

struct DetailView: View {
    let item: URL

    var body: some View {
        AsyncImage(url: item) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "mushy1", withExtension: "jpg") {
            DetailView(item: url)
        }
    }
}
