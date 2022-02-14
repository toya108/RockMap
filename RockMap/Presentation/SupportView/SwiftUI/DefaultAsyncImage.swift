import SwiftUI
import SkeletonUI

struct DefaultAsyncImage: View {

    let url: URL?

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else if phase.error != nil {
                Resources.Images.Assets.noimage.image
            } else {
                Color.clear.skeleton(with: true)
            }
        }
    }
}

struct DefaultAsyncImage_Previews: PreviewProvider {
    static var previews: some View {
        DefaultAsyncImage(url: nil)
    }
}
