//
//  UserRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

struct UserRouter: RouterProtocol {
    
    typealias Destination = DestinationType
    typealias ViewModel = UserViewModel

    enum DestinationType: DestinationProtocol {
        case courseDetail(FIDocument.Course)
        case rockList(DocumentRef?)
        case courseList(DocumentRef?)
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

            case .rockList(let userReference):
                pushRockList(context, userReference: userReference)

            case .courseList(let userReference):
                pushCourseList(context, userReference: userReference)

        }
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: FIDocument.Course
    ) {
        let viewModel = CourseDetailViewModel(course: course)
        let vc = CourseDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushRockList(
        _ from: UIViewController,
        userReference: DocumentRef?
    ) {
        let viewModel = RockListViewModel(userReference: userReference)
        let vc = RockListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseList(
        _ from: UIViewController,
        userReference: DocumentRef?
    ) {
        let viewModel = CourseListViewModel(userReference: userReference)
        let vc = CourseListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

}
