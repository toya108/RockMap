//
//  RockDetailRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit

struct RockDetailRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockDetailViewModel

    enum DestinationType: DestinationProtocol {
        case courseDetail(FIDocument.Course)
        case courseRegister
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
            case let .courseDetail(course):
                pushCourseDetail(from, course: course)

            case .courseRegister:
                presentCourseRegister(from)

        }
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: FIDocument.Course
    ) {
        let courseDetailViewModel = CourseDetailViewModel(course: course)
        from.navigationController?.pushViewController(
            CourseDetailViewController.createInstance(viewModel: courseDetailViewModel),
            animated: true
        )
    }

    private func presentCourseRegister(_ from: UIViewController) {

        guard
            AuthManager.shared.isLoggedIn
        else {
            from.showNeedsLoginAlert(message: "課題を登録するにはログインが必要です。ログインして登録を続けますか？")
            return
        }

        guard
            let viewModel = self.viewModel,
            let headerImageReference = viewModel.headerImageReference
        else {
            return
        }

        let courseRegisterViewModel = CourseRegisterViewModel(
            registerType: .create(
                .init(
                    rock: viewModel.rockDocument,
                    rockImageReference: headerImageReference
                )
            )
        )

        let vc = RockMapNavigationController(
            rootVC: CourseRegisterViewController.createInstance(viewModel: courseRegisterViewModel),
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }
}
