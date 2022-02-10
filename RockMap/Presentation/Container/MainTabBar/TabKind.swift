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
                return Resources.Images.System.magnifyingglassCircle.uiImage

            case .map:
                return Resources.Images.System.mapCircle.uiImage

            case .myPage:
                return Resources.Images.System.personCircle.uiImage
        }
    }

    private var selectedImage: UIImage {
        switch self {
            case.search:
                return Resources.Images.System.magnifyingglassCircleFill.uiImage

            case .map:
                return Resources.Images.System.mapCircleFill.uiImage

            case .myPage:
                return Resources.Images.System.personCircleFill.uiImage
        }
    }
}

extension TabKind: Identifiable {
    var id: Self { self }
}
