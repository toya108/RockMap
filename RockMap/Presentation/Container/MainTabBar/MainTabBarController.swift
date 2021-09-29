import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewControllers()
        self.setupTabItem()
        self.setupLayout()
    }

    private func setupViewControllers() {
        setViewControllers(ScreenType.allCases.map(\.viewController), animated: true)
    }

    private func setupTabItem() {
        guard let viewControllers = viewControllers else { return }

        zip(viewControllers.map(\.tabBarItem), ScreenType.allCases).forEach {
            $0.0?.title = $0.1.tabName
            $0.0?.image = $0.1.image
            $0.0?.selectedImage = $0.1.selectedImage
        }
    }

    private func setupLayout() {
        UITabBar.appearance().barTintColor = UIColor.Pallete.primaryGreen
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance()
            .backgroundImage = UIGraphicsImageRenderer(size: .init(width: 1, height: 1))
            .image { context in
                UIColor.Pallete.primaryGreen.setFill()
                context.fill(.init(origin: .init(x: 0, y: 0), size: .init(width: 1, height: 1)))
            }
        UITabBar.appearance().shadowImage = UIImage()
        UITabBarItem.appearance()
            .setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)

        tabBar.layer.shadowColor = Resources.Const.UI.Shadow.color
        tabBar.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        tabBar.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        tabBar.layer.shadowOffset = .init(width: 0, height: -2)

        let appearance = UITabBarAppearance()
        let stackedLayoutAppearance = UITabBarItemAppearance()
        stackedLayoutAppearance.normal.iconColor = .white
        stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance = stackedLayoutAppearance
        appearance.backgroundColor = UIColor.Pallete.primaryGreen
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
