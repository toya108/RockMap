import SwiftUI
import Auth

struct MyPageView: UIViewControllerRepresentable {

    typealias UIViewControllerType = RockMapNavigationController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MyPageView>
    ) -> MyPageView.UIViewControllerType {
        return RockMapNavigationController(
            rootVC: MyPageViewController.createInstance(
                viewModel: .init(userKind: AuthManager.shared.isLoggedIn ? .mine : .guest)
            ),
            naviBarClass: RockMapNavigationBar.self
        )
    }

    func updateUIViewController(
        _ uiViewController: MyPageView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<MyPageView>
    ) {
    }
}
