import UIKit

struct RockConfirmRouter: RouterProtocol {
    typealias Destination = DestinationType
    typealias ViewModel = RockConfirmViewModel

    enum DestinationType: DestinationProtocol {
        case dismiss
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
        case .dismiss:
            self.dismiss(from)
        }
    }

    private func dismiss(_ from: UIViewController) {
        RegisterSucceededViewController.showSuccessView(present: from) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                from.rootViewController?.dismiss(animated: true)
                NotificationCenter.default.post(name: .didRockRegisterFinished, object: nil)
            }
        }
    }
}
