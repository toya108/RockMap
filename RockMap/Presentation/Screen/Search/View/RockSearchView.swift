import SwiftUI

struct RockSearchView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<RockSearchView>
    ) -> RockSearchView.UIViewControllerType {
        return UINavigationController(
            rootViewController: RockSearchViewController.createInstance(viewModel: .init())
        )
    }

    func updateUIViewController(
        _ uiViewController: RockSearchView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<RockSearchView>
    ) {
    }
}
