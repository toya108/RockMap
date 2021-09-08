
import Auth
import UIKit

extension UIViewController {
    func getFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        return view.subviews.lazy.compactMap {
            return self.getFirstResponder(view: $0)
        }.first
    }

    func getVisibleViewController() -> UIViewController? {
        guard
            let rootViewController = rootViewController
        else {
            return nil
        }

        return self.getVisibleViewController(rootViewController)
    }

    private func getVisibleViewController(_ rootViewController: UIViewController)
        -> UIViewController?
    {
        if let presentedViewController = rootViewController.presentedViewController {
            return self.getVisibleViewController(presentedViewController)
        }

        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }

        if let tabBarController = rootViewController as? UITabBarController {
            if
                let navigationController = tabBarController
                    .selectedViewController as? UINavigationController
            {
                let visible = navigationController.visibleViewController

                if visible is UISearchController || visible is UIAlertController {
                    return visible?.presentingViewController ?? visible?.parent
                }

                return visible
            }
            return tabBarController.selectedViewController
        }

        return rootViewController
    }

    var rootViewController: UIViewController? {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
    }

    func topViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return self.topViewController(controller: selected)
            }
        }

        if let navigationController = controller as? UINavigationController {
            return self.topViewController(controller: navigationController.visibleViewController)
        }

        if let presented = controller?.presentedViewController {
            return self.topViewController(controller: presented)
        }

        return controller
    }

    func showOKAlert(
        title: String,
        message: String = "",
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func showAlert(
        title: String,
        message: String? = nil,
        actions: [UIAlertAction],
        style: UIAlertController.Style = .alert
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: style
        )

        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }

    func showNeedsLoginAlert(message: String) {
        if AuthManager.shared.isLoggedIn { return }

        self.showAlert(
            title: "ログインが必要です。",
            message: message,
            actions: [
                .init(title: "OK", style: .default) { [weak self] _ in

                    guard let self = self else { return }

                    guard
                        let authViewController = AuthManager.shared.authViewController
                    else {
                        return
                    }

                    let vc = RockMapNavigationController(
                        rootVC: authViewController,
                        naviBarClass: RockMapNavigationBar.self
                    )
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                },
                .init(title: "Cancel", style: .cancel),
            ],
            style: .alert
        )
    }
}
