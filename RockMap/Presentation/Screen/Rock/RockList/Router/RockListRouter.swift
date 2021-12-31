import UIKit

struct RocklistRouter: RouterProtocol {
    typealias Destination = DestinationType
    typealias ViewModel = RockListViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(Entity.Rock)
        case rockRegister(Entity.Rock)
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: DestinationType,
        from context: UIViewController
    ) {
        switch destination {
        case let .rockDetail(rock):
            self.pushRockDetail(context, rock: rock)

        case let .rockRegister(rock):
            self.presentCourseRegister(context, rock: rock)
        }
    }

    private func pushRockDetail(
        _ from: UIViewController,
        rock: Entity.Rock
    ) {
        let viewModel = RockDetailViewModel(rock: rock)
        let vc = RockDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentCourseRegister(
        _ from: UIViewController,
        rock: Entity.Rock
    ) {
        let viewModel = RockRegisterViewModel(registerType: .edit(rock))
        let vc = UINavigationController(
            rootViewController: RockRegisterViewController.createInstance(viewModel: viewModel)
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }
}
