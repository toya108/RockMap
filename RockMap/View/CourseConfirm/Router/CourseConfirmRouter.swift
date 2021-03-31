//
//  CourseConfirmRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import UIKit

struct CourseConfirmRouter: RouterProtocol {

    typealias Destination = DestinationType

    enum DestinationType: DestinationProtocol {
        case rockDetail
    }

    private weak var viewModel: CourseConfirmViewModel!

    init(viewModel: CourseConfirmViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .rockDetail:
                dismissToRockDetail(from)

        }
    }

    private func dismissToRockDetail(_ from: UIViewController) {

        RegisterSucceededViewController.showSuccessView(present: from) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.dismiss(animated: true) {

                    guard
                        let rockDetailViewController = from.getVisibleViewController() as? RockDetailViewController
                    else {
                        return
                    }

                    rockDetailViewController.updateCouses()
                }
            }
        }
    }
}
