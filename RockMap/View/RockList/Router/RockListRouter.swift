//
//  RockListRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import UIKit

struct RocklistRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockListViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(FIDocument.Rock)
        case rockRegister(FIDocument.Rock)
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
            case .rockDetail(let rock):
                pushRockDetail(context, rock: rock)

            case .rockRegister(let rock):
                presentCourseRegister(context, rock: rock)

        }
    }

    private func pushRockDetail(
        _ from: UIViewController,
        rock: FIDocument.Rock
    ) {
        let viewModel = RockDetailViewModel(rock: rock)
        let vc = RockDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentCourseRegister(
        _ from: UIViewController,
        rock: FIDocument.Rock
    ) {
        let viewModel = RockRegisterViewModel(
            registerType: .edit(rock)
        )
        let vc = RockMapNavigationController(
            rootVC: RockRegisterViewController.createInstance(viewModel: viewModel),
            naviBarClass: RockMapNavigationBar.self
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }

}
