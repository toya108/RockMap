import SwiftUI
import Auth

struct MyPageView: UIViewControllerRepresentable {

    typealias UIViewControllerType = MyPageViewController

    let userKind: MyPageViewModel.UserKind

    init(userKind: MyPageViewModel.UserKind) {
        self.userKind = userKind
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MyPageView>
    ) -> MyPageView.UIViewControllerType {
        MyPageViewController.createInstance(
            viewModel: .init(userKind: userKind)
        )
    }

    func updateUIViewController(
        _ uiViewController: MyPageView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<MyPageView>
    ) {
    }
}
