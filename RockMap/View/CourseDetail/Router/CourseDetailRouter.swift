//
//  CourseDetailRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/03.
//

import UIKit

struct CourseDetailRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = CourseDetailViewModel

    enum DestinationType: DestinationProtocol {
        case registerClimbed
        case climbedUserList
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
            case .registerClimbed:
                presentRegisterClimbedBottomSheet(from)

            case .climbedUserList:
                pushClimbedUserList(from)

        }
    }

    private func presentRegisterClimbedBottomSheet(_ from: UIViewController) {

        guard
            AuthManager.shared.isLoggedIn
        else {
            from.showNeedsLoginAlert(message: "完登を記録するにはログインが必要です。ログインして完登を記録しますか？")
            return
        }

        let vm = RegisterClimbedViewModel(registerType: .create(viewModel.course))
        let vc = RegisterClimbedBottomSheetViewController.createInstance(viewModel: vm)

        from.present(vc, animated: true)
    }

    private func pushClimbedUserList(_ from: UIViewController) {
        from.navigationController?.pushViewController(
            ClimbedUserListViewController.createInstance(course: viewModel.course),
            animated: true
        )
    }

}
