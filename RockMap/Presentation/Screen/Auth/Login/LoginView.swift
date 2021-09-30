import SwiftUI

struct LoginView: UIViewControllerRepresentable {

    typealias UIViewControllerType = LoginViewController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<LoginView>
    ) -> LoginView.UIViewControllerType {
        return UIStoryboard(
            name: LoginViewController.className,
            bundle: nil
        ).instantiateInitialViewController() as! LoginViewController
    }

    func updateUIViewController(
        _ uiViewController: LoginView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<LoginView>
    ) {
    }
}
