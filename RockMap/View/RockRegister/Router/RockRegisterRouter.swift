//
//  RockRegisterRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit

struct RockRegisterRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockRegisterViewModel

    enum DestinationType: DestinationProtocol {
        case rockConfirm
        case rockSearch
        case locationSelect
    }

    weak var viewModel: RockRegisterViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .rockConfirm:
                pushRockConfirm(from)

            case .rockSearch:
                dismissToRockSearch(from)

            case .locationSelect:
                presentLocationSelect(from)

        }
    }

    private func pushRockConfirm(
        _ from: UIViewController
    ) {

        guard
            viewModel.callValidations(),
            let headerImage = self.viewModel?.rockHeaderImage
        else {
            from.showOKAlert(
                title: "入力内容に不備があります。",
                message: "入力内容を見直してください。"
            )
            return
        }

        let viewModel = RockConfirmViewModel(
            rockName: self.viewModel.rockName,
            rockImageDatas: self.viewModel.rockImageDatas,
            rockHeaderImage: headerImage,
            rockLocation: self.viewModel.rockLocation,
            rockDesc: self.viewModel.rockDesc,
            seasons: self.viewModel.seasons,
            lithology: self.viewModel.lithology
        )

        from.navigationController?.pushViewController(
            RockConfirmViewController.createInstance(viewModel: viewModel),
            animated: true
        )
    }

    private func dismissToRockSearch(_ from: UIViewController) {
        from.showAlert(
            title: "編集内容を破棄しますか？",
            actions: [
                .init(title: "破棄", style: .destructive) { _ in
                    from.dismiss(animated: true)
                },
                .init(title: "キャンセル", style: .cancel)
            ],
            style: .actionSheet
        )
    }

    private func presentLocationSelect(
        _ from: UIViewController
    ) {
        guard
            let location = viewModel?.rockLocation.location
        else {
            return
        }

        let stroryBoard = UIStoryboard(
            name: RockLocationSelectViewController.className,
            bundle: nil
        )

        let vc = stroryBoard.instantiateInitialViewController { coder in
            return RockLocationSelectViewController(
                coder: coder,
                location: location
            )
        }

        guard
            let locationSelectViewController = vc
        else {
            return
        }

        from.present(
            RockMapNavigationController(
                rootVC: locationSelectViewController,
                naviBarClass: RockMapNavigationBar.self
            ),
            animated: true
        )

    }
}
