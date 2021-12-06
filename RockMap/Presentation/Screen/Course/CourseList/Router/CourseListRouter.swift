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
        case let .courseDetail(course):
            self.pushCourseDetail(context, course: course)

        case let .courseRegister(course):
            self.presentCourseRegister(context, course: course)
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
        let vc = UINavigationController(
            rootViewController: CourseRegisterViewController.createInstance(viewModel: viewModel)
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }
}
