import UIKit
import SwiftUI

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
            self.pushClimbedCourseList(context)

        case let .courseDetail(course):
            self.pushCourseDetail(context, course: course)

        case .rockList:
            self.pushRockList(context)

        case .courseList:
            self.pushCourseList(context)

        case let .editProfile(user):
            self.presentEditProfile(context, user: user)

        case .settings:
            self.presentSettings(context)
        }
    }

    private func pushClimbedCourseList(
        _ from: UIViewController
    ) {
        let vc = UIHostingController(
            rootView: ClimbedCourseListView(viewModel: .init(userId: viewModel.userKind.userId))
        )
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: Entity.Course
    ) {
        let viewModel = CourseDetailViewModel(course: course)
        let vc = CourseDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushRockList(_ from: UIViewController) {
        let vc = UIHostingController(
            rootView: RegisteredRockListView(viewModel: .init(userId: viewModel.userKind.userId))
        )
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseList(_ from: UIViewController) {
        let vc = UIHostingController(
            rootView: RegisteredCourseListView(viewModel: .init(userId: viewModel.userKind.userId))
        )
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentEditProfile(
        _ from: UIViewController,
        user: Entity.User
    ) {
        let viewModel = EditProfileViewModel(user: user)
        let vc = EditProfileViewController.createInstance(viewModel: viewModel)
        let nc = UINavigationController(rootViewController: vc)
        nc.isModalInPresentation = true
        from.present(nc, animated: true)
    }

    private func presentSettings(
        _ from: UIViewController
    ) {
        from.present(
            UIHostingController(rootView: SettingsView()),
            animated: true
        )
    }
}
