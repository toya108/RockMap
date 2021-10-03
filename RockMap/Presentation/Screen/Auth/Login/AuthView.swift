import Auth
import SwiftUI

public struct AuthView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UINavigationController

    public init() { }

    public func makeUIViewController(context: Context) -> UINavigationController {
        guard let authViewController = AuthManager.shared.authViewController else {
            assertionFailure()
            return UINavigationController()
        }

        return RockMapNavigationController(
            rootVC: authViewController,
            naviBarClass: RockMapNavigationBar.self
        )
    }

    public func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {

    }
}
