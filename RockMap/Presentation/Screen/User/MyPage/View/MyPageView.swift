import SwiftUI
import Auth

struct MyPageView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MyPageView>
    ) -> MyPageView.UIViewControllerType {
        return UINavigationController(
            rootViewController: MyPageViewController.createInstance(
                viewModel: .init(userKind: AuthManager.shared.isLoggedIn ? .mine : .guest)
            )
        )
    }

    func updateUIViewController(
        _ uiViewController: MyPageView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<MyPageView>
    ) {
    }
}
