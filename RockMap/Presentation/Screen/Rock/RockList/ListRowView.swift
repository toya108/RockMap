import SwiftUI

struct ListRowView: View {

    private let imageURL: URL?
    private let iconImage: UIImage
    private let title: String
    private let firstLabel: String
    private let firstText: String
    private let secondLabel: String
    private let secondText: String
    private let thirdText: String?

    init(
        imageURL: URL?,
        iconImage: UIImage,
        title: String,
        firstLabel: String,
        firstText: String,
        secondLabel: String,
        secondText: String,
        thirdText: String?
    ) {
        self.imageURL    = imageURL
        self.iconImage   = iconImage
        self.title       = title
        self.firstLabel  = firstLabel
        self.firstText   = firstText
        self.secondLabel = secondLabel
        self.secondText  = secondText
        self.thirdText   = thirdText
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(
                url: imageURL,
                content: { image in
                    image.resizable().scaledToFill()
                },
                placeholder: {
                    ProgressView()
                }
            )
            .frame(width: 80, height: 80, alignment: .center)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                HStack {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                    Text(title).fontWeight(.semibold).lineLimit(1)
                }
                HStack {
                    Text(firstLabel).font(.caption).fontWeight(.semibold)
                    Text(firstText).font(.caption).lineLimit(1)
                }
                HStack {
                    Text(secondLabel).font(.caption).fontWeight(.semibold)
                    Text(secondText).font(.caption).lineLimit(1)
                }
                if let thirdText = thirdText {
                    Text(thirdText).font(.caption).lineLimit(1)
                }
            }
        }
        .padding(8)
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(
            imageURL: URL(string: "https://1.bp.blogspot.com/-7uiCs6dI4a0/YEGQA-8JOrI/AAAAAAABddA/qPFt2E8vDfQwPQsAYLvk4lowkwP-GN7VQCNcBGAsYHQ/s180-c/buranko_girl_smile.png")!,
            iconImage: UIImage.AssetsImages.rockFill,
            title: "サンプル岩",
            firstLabel: "登録日",
            firstText: "2021/02/21",
            secondLabel: "住所",
            secondText: "東京都千代田区",
            thirdText: "これは岩です。"
        )
        .frame(width: 414, height: 116, alignment: .center)
    }
}
