import Auth
import SwiftUI

struct AuthView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    private let coordinator: AuthCoordinatorProtocol

    init(coordinator: AuthCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func makeCoordinator() -> AuthCoordinatorProtocol {
        self.coordinator
    }

    func makeUIViewController(context: Context) -> UINavigationController {

        guard
            let authViewController = AuthUIAccessor().authViewController(
                coordinator: context.coordinator
            )
        else {
            assertionFailure()
            return UINavigationController()
        }

        return UINavigationController(rootViewController: authViewController)
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {

    }
}
