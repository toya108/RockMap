import SwiftUI

struct MainTabView: View {

    @State private var selection: TabKind = .rockSearch

    var body: some View {
        TabView(selection: $selection) {
            ForEach(TabKind.allCases) {
                $0.makeTab(selection: selection)
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
        MainTabView()
    }
}
