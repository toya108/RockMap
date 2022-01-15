import SwiftUI

enum TabKind: CaseIterable {

    case home
    case rockSearch
    case myPage

    @ViewBuilder
    func makeTab(selection: TabKind) -> some View {
        switch self {
            case .home:
                HomeView(viewModel: .init()).tabItem {
                    TabKind.home.makeStack(selection: selection)
                }
                .tag(TabKind.home)

            case .rockSearch:
                RockSearchView().tabItem {
                    TabKind.rockSearch.makeStack(selection: selection)
                }
                .tag(TabKind.rockSearch)
                .edgesIgnoringSafeArea(.all)

            case .myPage:
                MyPageView().tabItem {
                    TabKind.myPage.makeStack(selection: selection)
                }
                .tag(TabKind.myPage)
                .edgesIgnoringSafeArea(.all)
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
            case .home:
                return .init("Home")

            case .rockSearch:
                return .init("rock_search")

            case .myPage:
                return .init("mypage")
        }
    }

    private var normalImage: UIImage {
        switch self {
            case .home:
                return UIImage.SystemImages.house

            case .rockSearch:
                return UIImage.SystemImages.map

            case .myPage:
                return UIImage.SystemImages.personCircle
        }
    }

    private var selectedImage: UIImage {
        switch self {
            case.home:
                return UIImage.SystemImages.houseFill

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
