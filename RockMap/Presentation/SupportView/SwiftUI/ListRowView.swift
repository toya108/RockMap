import SwiftUI

struct ListRowView: View {

    private let imageURL: URL?
    private let iconImage: UIImage
    private let iconSize: CGSize
    private let title: String
    private let firstLabel: LocalizedStringKey
    private let firstText: String
    private let secondLabel: LocalizedStringKey
    private let secondText: String
    private let thirdText: String?

    init(
        imageURL: URL?,
        iconImage: UIImage,
        iconSize: CGSize,
        title: String,
        firstLabel: LocalizedStringKey,
        firstText: String,
        secondLabel: LocalizedStringKey,
        secondText: String,
        thirdText: String?
    ) {
        self.imageURL    = imageURL
        self.iconImage   = iconImage
        self.iconSize    = iconSize
        self.title       = title
        self.firstLabel  = firstLabel
        self.firstText   = firstText
        self.secondLabel = secondLabel
        self.secondText  = secondText
        self.thirdText   = thirdText
    }

    init(rock: Entity.Rock) {
        self.imageURL = rock.headerUrl
        self.iconImage = Resources.Images.Assets.rockFill.uiImage
        self.iconSize = .init(width: 24, height: 24)
        self.title = rock.name
        self.firstLabel = .init("registered_date")
        self.firstText = rock.createdAt.string(dateStyle: .medium)
        self.secondLabel = .init("area")
        self.secondText = rock.area ?? ""
        self.thirdText = rock.desc
    }

    init(course: Entity.Course) {
        self.imageURL = course.headerUrl
        self.iconImage = Resources.Images.System.docPlaintextFill.uiImage
        self.iconSize = .init(width: 16, height: 16)
        self.title = course.name
        self.firstLabel = .init("registered_date")
        self.firstText = course.createdAt.string(dateStyle: .medium)
        self.secondLabel = .init("grade")
        self.secondText = course.grade.name
        self.thirdText = course.desc
    }

    init(course: Entity.Course, record: Entity.ClimbRecord) {
        self.imageURL = course.headerUrl
        self.iconImage = Resources.Images.System.docPlaintextFill.uiImage
        self.iconSize = .init(width: 16, height: 16)
        self.title = course.name
        self.firstLabel = .init("registered_date")
        self.firstText = course.createdAt.string(dateStyle: .medium)
        self.secondLabel = .init("grade")
        self.secondText = course.grade.name
        self.thirdText = course.desc
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

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(uiImage: iconImage)
                        .resizable()
                        .frame(width: iconSize.width, height: iconSize.height)
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
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(
            imageURL: URL(string: "https://1.bp.blogspot.com/-7uiCs6dI4a0/YEGQA-8JOrI/AAAAAAABddA/qPFt2E8vDfQwPQsAYLvk4lowkwP-GN7VQCNcBGAsYHQ/s180-c/buranko_girl_smile.png")!,
            iconImage: Resources.Images.Assets.rockFill.uiImage,
            iconSize: .init(width: 24, height: 24),
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
