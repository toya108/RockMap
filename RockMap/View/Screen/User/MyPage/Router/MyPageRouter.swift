//
//  MyPageRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

struct MyPageRouter: RouterProtocol {
    
    typealias Destination = DestinationType
    typealias ViewModel = MyPageViewModel

    enum DestinationType: DestinationProtocol {
        case climbedCourseList
        case courseDetail(Entity.Course)
        case rockList
        case courseList
        case editProfile(Entity.User)
        case settings
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
            case .climbedCourseList:
                pushClimbedCourseList(context)

            case .courseDetail(let course):
                pushCourseDetail(context, course: course)

            case .rockList:
                pushRockList(context)

            case .courseList:
                pushCourseList(context)

            case .editProfile(let user):
                presentEditProfile(context, user: user)

            case .settings:
                presentSettings(context)
        }
    }

    private func pushClimbedCourseList(
        _ from: UIViewController
    ) {
        let vc = MyClimbedListViewController.createInstance(viewModel: .init())
        from.navigationController?.pushViewController(vc, animated: true)
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

    private func pushRockList(_ from: UIViewController) {
        let viewModel = RockListViewModel(userId: viewModel.userKind.userId)
        let vc = RockListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseList(_ from: UIViewController) {
        let viewModel = CourseListViewModel(userId: viewModel.userKind.userId)
        let vc = CourseListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentEditProfile(
        _ from: UIViewController,
        user: Entity.User
    ) {
        let viewModel = EditProfileViewModel(user: user)
        let vc = EditProfileViewController.createInstance(viewModel: viewModel)
        let nc = RockMapNavigationController(rootVC: vc, naviBarClass: RockMapNoShadowNavigationBar.self)
        nc.isModalInPresentation = true
        from.present(nc, animated: true)
    }

    private func presentSettings(
        _ from: UIViewController
    ) {
        let nc = RockMapNavigationController(rootVC: SettingsViewController(), naviBarClass: RockMapNoShadowNavigationBar.self)
        from.present(nc, animated: true)
    }

}
