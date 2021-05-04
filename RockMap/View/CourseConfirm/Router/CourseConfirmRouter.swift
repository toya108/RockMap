//
//  CourseConfirmRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import UIKit

struct CourseConfirmRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = CourseConfirmViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail
    }

    weak var viewModel: CourseConfirmViewModel!

    init(viewModel: ViewModel) {
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

                UIApplication.shared.windows
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController?
                    .dismiss(animated: true)

                guard
                    let tabbarVC = from.presentingViewController as? UITabBarController,
                    let nc = tabbarVC.selectedViewController as? UINavigationController,
                    let vc = nc.viewControllers.last,
                    let presentedVc = vc as? CourseRegisterDetectableViewControllerProtocol
                else {
                    return
                }

                presentedVc.didCourseRegisterFinished()
            }
        }
    }
}
