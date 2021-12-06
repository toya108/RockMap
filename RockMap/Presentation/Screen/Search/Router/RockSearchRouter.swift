import Auth
import CoreLocation
import UIKit

struct RockSeachRouter: RouterProtocol {
    typealias Destination = DestinationType
    typealias ViewModel = RockSearchViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(Entity.Rock)
        case rockRegister(CLLocation)
    }

    internal weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
        case let .rockDetail(rock):
            self.pushRockDetail(from, rock: rock)

        case let .rockRegister(location):
            self.presentRockRegister(
                from,
                location: location
            )
        }
    }

    private func pushRockDetail(
        _ from: UIViewController,
        rock: Entity.Rock
    ) {
        let rockDetailViewModel = RockDetailViewModel(rock: rock)
        from.navigationController?.pushViewController(
            RockDetailViewController.createInstance(viewModel: rockDetailViewModel),
            animated: true
        )
    }

    private func presentRockRegister(
        _ from: UIViewController,
        location: CLLocation
    ) {
        guard
            AuthManager.shared.isLoggedIn
        else {
            from.showNeedsLoginAlert(message: "岩情報を登録するにはログインが必要です。ログインして登録を続けますか？")
            return
        }

        let rockRegisterViewModel = RockRegisterViewModel(registerType: .create(location))
        let registerVc = RockRegisterViewController.createInstance(viewModel: rockRegisterViewModel)
        let vc = UINavigationController(rootViewController: registerVc)
        vc.isModalInPresentation = true

        from.present(vc, animated: true)
    }
}
