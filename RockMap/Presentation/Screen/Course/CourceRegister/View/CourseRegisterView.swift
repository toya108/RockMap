import SwiftUI

struct CourseRegisterView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    let registerType: CourseRegisterViewModel.RegisterType

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<CourseRegisterView>
    ) -> CourseRegisterView.UIViewControllerType {
        UINavigationController(
            rootViewController: CourseRegisterViewController.createInstance(
                viewModel: .init(registerType: registerType)
            )
        )
    }

    func updateUIViewController(
        _ uiViewController: RockRegisterView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<CourseRegisterView>
    ) {}
}
