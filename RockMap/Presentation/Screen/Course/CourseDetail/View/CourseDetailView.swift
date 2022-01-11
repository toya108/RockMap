import SwiftUI

struct CourseDetailView: UIViewControllerRepresentable {

    typealias UIViewControllerType = CourseDetailViewController

    let course: Entity.Course

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<CourseDetailView>
    ) -> CourseDetailView.UIViewControllerType {
        CourseDetailViewController.createInstance(
            viewModel: .init(course: course)
        )
    }

    func updateUIViewController(
        _ uiViewController: CourseDetailView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<CourseDetailView>
    ) {}
}
