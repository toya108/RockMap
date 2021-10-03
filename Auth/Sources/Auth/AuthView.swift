import SwiftUI
import FirebaseAuthUI

public struct AuthView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UINavigationController

    public init() { }

    public func makeUIViewController(context: Context) -> UINavigationController {
        guard let authViewController = AuthManager.shared.authUI?.authViewController() else {
            assertionFailure()
            return UINavigationController()
        }
        return authViewController
    }

    public func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {

    }
}
