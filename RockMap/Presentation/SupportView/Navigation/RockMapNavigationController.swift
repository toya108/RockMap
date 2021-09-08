import UIKit

class RockMapNavigationController: UINavigationController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(
        rootVC: UIViewController,
        naviBarClass: AnyClass?,
        toolbarClass: AnyClass? = nil
    ) {
        self.init(navigationBarClass: naviBarClass, toolbarClass: toolbarClass)
        self.viewControllers = [rootVC]
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let previousVcIndex = viewControllers.count - 1

        guard
            let previousVc = viewControllers.any(at: previousVcIndex)
        else {
            return
        }

        previousVc.navigationItem.backButtonDisplayMode = .minimal
        super.pushViewController(viewController, animated: animated)
    }
}
