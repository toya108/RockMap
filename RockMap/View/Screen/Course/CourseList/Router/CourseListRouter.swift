//
//  CourseListRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/05.
//

import UIKit

struct CourselistRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = CourseListViewModel

    enum DestinationType: DestinationProtocol {
        case courseDetail(Entity.Course)
        case courseRegister(Entity.Course)
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
            case .courseDetail(let course):
                pushCourseDetail(context, course: course)

            case .courseRegister(let course):
                presentCourseRegister(context, course: course)

        }
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: Entity.Course
    ) {
        let viewModel = CourseDetailViewModel(course: course)
        let vc = CourseDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentCourseRegister(
        _ from: UIViewController,
        course: Entity.Course
    ) {
        let viewModel = CourseRegisterViewModel(
            registerType: .edit(course)
        )
        let vc = RockMapNavigationController(
            rootVC: CourseRegisterViewController.createInstance(viewModel: viewModel),
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }

}
