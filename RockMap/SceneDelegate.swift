
import Auth
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: scene)
        self.window = window
        window.makeKeyAndVisible()

        var initialViewController: UIViewController {
            if AuthManager.shared.isLoggedIn {
                return MainTabBarController()
            } else {
                let vc = UIStoryboard(name: LoginViewController.className, bundle: nil)
                    .instantiateInitialViewController()!
                return UINavigationController(rootViewController: vc)
            }
        }

        window.rootViewController = initialViewController
    }
}
