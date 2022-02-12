import SwiftUI

struct DefaultAsyncImage: View {

    let url: URL?

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        AsyncImage(
            url: url,
            content: { image in
                image.resizable().scaledToFill()
            },
            placeholder: {
                ProgressView()
            }
        )
    }
}

struct DefaultAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        DefaultAsyncImage(url: nil)
    }
}
