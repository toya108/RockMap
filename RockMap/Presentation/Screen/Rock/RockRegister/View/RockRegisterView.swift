import SwiftUI

struct RockRegisterView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    let registerType: RockRegisterViewModel.RegisterType

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<RockRegisterView>
    ) -> RockRegisterView.UIViewControllerType {
        UINavigationController(
            rootViewController: RockRegisterViewController.createInstance(
                viewModel: .init(registerType: registerType)
            )
        )
    }

    func updateUIViewController(
        _ uiViewController: RockRegisterView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<RockRegisterView>
    ) {}
}
