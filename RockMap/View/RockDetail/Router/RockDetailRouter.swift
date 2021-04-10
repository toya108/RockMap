//
//  RockDetailRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit

struct RockDetailRouter: RouterProtocol {

    typealias Destination = DestinationType

    enum DestinationType: DestinationProtocol {
        case courseDetail(FIDocument.Course)
        case courseRegister
    }

    private weak var viewModel: RockDetailViewModel?

    init(viewModel: RockDetailViewModel) {
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
            let viewModel = self.viewModel,
            let headerImageReference = viewModel.headerImageReference
        else {
            return
        }

        let courseRegisterViewModel = CourseRegisterViewModel(
            rockHeaderStructure: .init(
                rock: viewModel.rockDocument,
                rockImageReference: headerImageReference
            )
        )

        let vc = RockMapNavigationController(
            rootVC: CourseRegisterViewController.createInstance(viewModel: courseRegisterViewModel),
            naviBarClass: RockMapNavigationBar.self
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }
}
