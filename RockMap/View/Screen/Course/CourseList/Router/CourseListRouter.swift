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
        let courseDocument = FIDocument.Course(
            id: course.id,
            parentPath: course.parentPath,
            createdAt: course.createdAt,
            updatedAt: course.updatedAt,
            name: course.name,
            desc: course.desc,
            grade: .init(rawValue: course.grade.rawValue) ?? .q10,
            shape: Set(course.shape.compactMap { .init(rawValue: $0.rawValue) }),
            parentRockName: course.parentRockName,
            parentRockId: course.parentRockId,
            registeredUserId: course.registeredUserId,
            headerUrl: course.headerUrl,
            imageUrls: course.imageUrls
        )
        let viewModel = CourseDetailViewModel(course: courseDocument)
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
