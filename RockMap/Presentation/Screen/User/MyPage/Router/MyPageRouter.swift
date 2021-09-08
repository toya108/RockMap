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
        let vc = MyClimbedListViewController.createInstance(viewModel: .init())
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
        let nc = RockMapNavigationController(
            rootVC: vc,
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        nc.isModalInPresentation = true
        from.present(nc, animated: true)
    }

    private func presentSettings(
        _ from: UIViewController
    ) {
        let nc = RockMapNavigationController(
            rootVC: SettingsViewController(),
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        from.present(nc, animated: true)
    }
}
