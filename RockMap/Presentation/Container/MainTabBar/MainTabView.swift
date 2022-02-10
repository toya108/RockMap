import SwiftUI
import Auth

struct MainTabView: View {

    @State private var selection: TabKind = .search
    let authAccessor: AuthAccessorProtocol

    init(authAccessor: AuthAccessorProtocol) {
        self.authAccessor = authAccessor
    }

    var body: some View {
        TabView(selection: $selection) {
            ForEach(TabKind.allCases) {
                switch $0 {
                    case .search:
                        SearchRootView(viewModel: .init()).tabItem {
                            TabKind.search.makeStack(selection: selection)
                        }
                        .tag(TabKind.search)

                    case .map:
                        MapView().tabItem {
                            TabKind.map.makeStack(selection: selection)
                        }
                        .tag(TabKind.map)
                        .edgesIgnoringSafeArea(.all)

                    case .myPage:
                        let myPageViewController = MyPageViewController.createInstance(
                            viewModel: .init(userKind: authAccessor.isLoggedIn ? .mine : .guest)
                        )
                        WrapInNavigationView(root: myPageViewController).tabItem {
                            TabKind.myPage.makeStack(selection: selection)
                        }
                        .tag(TabKind.myPage)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onAppear {
            setupAppearance()
        }
    }

    private func setupAppearance() {
        let tabItemAppearance = UITabBarItemAppearance()
        tabItemAppearance.normal.iconColor = .tertiarySystemBackground
        tabItemAppearance.selected.iconColor = .tertiarySystemBackground
        tabItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tertiarySystemBackground]
        tabItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tertiarySystemBackground]

        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance = tabItemAppearance
        appearance.inlineLayoutAppearance = tabItemAppearance
        appearance.compactInlineLayoutAppearance = tabItemAppearance
        appearance.backgroundColor = UIColor.Pallete.primaryGreen
        appearance.selectionIndicatorTintColor = .tertiarySystemBackground
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(authAccessor: AuthAccessor())
    }
}
