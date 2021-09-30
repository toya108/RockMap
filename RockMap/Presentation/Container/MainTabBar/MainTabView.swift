import SwiftUI

struct MainTabView: View {

    @State private var selection: TabKind = .rockSearch

    var body: some View {
        TabView(selection: $selection) {
            RockSearchView().tabItem {
                VStack {
                    Image(uiImage: self.selection == .rockSearch
                          ? UIImage.SystemImages.mapFill
                          : UIImage.SystemImages.map
                    )
                    Text("岩を探す")
                }
            }
            .edgesIgnoringSafeArea(.all)
            .tag(TabKind.rockSearch)
            MyPageView().tabItem {
                VStack {
                    Image(uiImage: self.selection == .myPage
                          ? UIImage.SystemImages.personCircleFill
                          : UIImage.SystemImages.personCircle
                    )
                    Text("マイページ")
                }
            }
            .tag(TabKind.myPage)
        }
        .onAppear {
            setupAppearance()
        }
    }

    private func setupAppearance() {
        let tabItemAppearance = UITabBarItemAppearance()
        tabItemAppearance.normal.iconColor = .white
        tabItemAppearance.selected.iconColor = .white
        tabItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        tabItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance = tabItemAppearance
        appearance.inlineLayoutAppearance = tabItemAppearance
        appearance.compactInlineLayoutAppearance = tabItemAppearance
        appearance.backgroundColor = UIColor.Pallete.primaryGreen
        appearance.selectionIndicatorTintColor = .white
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

enum TabKind: Hashable {
    case rockSearch
    case myPage
}
