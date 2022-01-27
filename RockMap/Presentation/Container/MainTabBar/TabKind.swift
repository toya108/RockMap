import SwiftUI

enum TabKind: CaseIterable {

    case search
    case map
    case myPage

    @ViewBuilder
    func makeStack(selection: TabKind) -> some View {
        VStack {
            self.makeImage(selection: selection)
            Text(titleKey)
        }
    }

    private func makeImage(selection: TabKind) -> Image {
        let image = self == selection
        ? self.selectedImage
        : self.normalImage

        return .init(uiImage: image)
    }

    private var titleKey: LocalizedStringKey {
        switch self {
            case .search:
                return .init("search")

            case .map:
                return .init("map")

            case .myPage:
                return .init("mypage")
        }
    }

    private var normalImage: UIImage {
        switch self {
            case .search:
                return UIImage.SystemImages.magnifyingglassCircle

            case .map:
                return UIImage.SystemImages.mapCircle

            case .myPage:
                return UIImage.SystemImages.personCircle
        }
    }

    private var selectedImage: UIImage {
        switch self {
            case.search:
                return UIImage.SystemImages.magnifyingglassCircleFill

            case .map:
                return UIImage.SystemImages.mapCircleFill

            case .myPage:
                return UIImage.SystemImages.personCircleFill
        }
    }
}

extension TabKind: Identifiable {
    var id: Self { self }
}
