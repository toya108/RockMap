//
//  RockConfirmRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit

struct RockConfirmRouter: RouterProtocol {

    typealias Destination = DestinationType

    enum DestinationType: DestinationProtocol {
        case rockSearch
    }

    private weak var viewModel: RockConfirmViewModel!

    init(viewModel: RockConfirmViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .rockSearch:
                dismissToRockSearch(from)

        }
    }

    private func dismissToRockSearch(_ from: UIViewController) {
        RegisterSucceededViewController.showSuccessView(present: from) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.windows
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController?
                    .dismiss(animated: true)
            }
        }
    }
}
