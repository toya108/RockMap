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
        HStack {
            AsyncImage(url: imageURL)
                .aspectRatio(.init(width: 96, height: 96), contentMode: .fill)
                .cornerRadius(8)
            VStack {
                HStack {
                    Image(uiImage: iconImage)
                    Text(title)
                }
                HStack {
                    Text(firstLabel)
                    Text(firstText)
                }
                HStack {
                    Text(secondLabel)
                    Text(secondText)
                }
                if let thirdText = thirdText {
                    Text(thirdText)
                }
            }
        }
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
