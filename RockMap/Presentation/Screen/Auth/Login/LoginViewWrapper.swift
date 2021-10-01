import SwiftUI

struct LoginViewWrapper: UIViewControllerRepresentable {

    typealias UIViewControllerType = LoginViewController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<LoginViewWrapper>
    ) -> LoginViewWrapper.UIViewControllerType {
        return UIStoryboard(
            name: LoginViewController.className,
            bundle: nil
        ).instantiateInitialViewController() as! LoginViewController
    }

    func updateUIViewController(
        _ uiViewController: LoginViewWrapper.UIViewControllerType,
        context: UIViewControllerRepresentableContext<LoginViewWrapper>
    ) {
    }
}
