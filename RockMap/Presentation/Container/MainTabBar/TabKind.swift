import SwiftUI

enum TabKind: CaseIterable {

    case rockSearch
    case myPage

    @ViewBuilder
    func makeTab(selection: TabKind) -> some View {
        switch self {
            case .rockSearch:
                RockSearchView().tabItem {
                    TabKind.rockSearch.makeStack(selection: selection)
                }
                .edgesIgnoringSafeArea(.all)
                .tag(TabKind.rockSearch)

            case .myPage:
                MyPageView().tabItem {
                    TabKind.myPage.makeStack(selection: selection)
                }
                .tag(TabKind.myPage)
        }
    }


    @ViewBuilder
    private func makeStack(selection: TabKind) -> some View {
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
            case .rockSearch:
                return .init("rock_search")

            case .myPage:
                return .init("mypage")
        }
    }

    private var normalImage: UIImage {
        switch self {
            case .rockSearch:
                return UIImage.SystemImages.map

            case .myPage:
                return UIImage.SystemImages.personCircle
        }
    }

    private var selectedImage: UIImage {
        switch self {
            case .rockSearch:
                return UIImage.SystemImages.mapFill

            case .myPage:
                return UIImage.SystemImages.personCircleFill
        }
    }
}

extension TabKind: Identifiable {
    var id: Self { self }
}
