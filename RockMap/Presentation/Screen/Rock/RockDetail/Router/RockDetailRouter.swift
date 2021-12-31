import Auth
import UIKit

struct RockDetailRouter: RouterProtocol {
    typealias Destination = DestinationType
    typealias ViewModel = RockDetailViewModel

    enum DestinationType: DestinationProtocol {
        case courseDetail(Entity.Course)
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
            self.pushCourseDetail(from, course: course)

        case .courseRegister:
            self.presentCourseRegister(from)
        }
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: Entity.Course
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

        let courseRegisterViewModel = CourseRegisterViewModel(
            registerType: .create(
                .init(
                    name: viewModel.rockDocument.name,
                    id: self.viewModel.rockDocument.id,
                    headerUrl: self.viewModel.rockDocument.headerUrl
                )
            )
        )

        let vc = UINavigationController(
            rootViewController: CourseRegisterViewController.createInstance(viewModel: courseRegisterViewModel)
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }
}
