import SwiftUI

struct RockSearchView: UIViewControllerRepresentable {

    typealias UIViewControllerType = RockMapNavigationController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<RockSearchView>
    ) -> RockSearchView.UIViewControllerType {
        return RockMapNavigationController(
            rootVC: RockSearchViewController.createInstance(viewModel: .init()),
            naviBarClass: RockMapNavigationBar.self
        )
    }

    func updateUIViewController(
        _ uiViewController: RockSearchView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<RockSearchView>
    ) {
    }
}
