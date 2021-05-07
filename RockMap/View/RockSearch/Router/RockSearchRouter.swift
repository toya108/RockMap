//
//  RockSearchRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit
import CoreLocation

struct RockSeachRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockSearchViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(FIDocument.Rock)
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
                pushRockDetail(from, rock: rock)

            case let .rockRegister(location):
                presentRockRegister(
                    from,
                    location: location
                )

        }
    }

    private func pushRockDetail(
        _ from: UIViewController,
        rock: FIDocument.Rock
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
        let vc = RockMapNavigationController(
            rootVC: registerVc,
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        vc.isModalInPresentation = true

        from.present(vc, animated: true)
    }
}
