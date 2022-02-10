import SwiftUI

struct WrapInNavigationView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<WrapInNavigationView>
    ) -> WrapInNavigationView.UIViewControllerType {
        UINavigationController(rootViewController: root)
    }

    func updateUIViewController(
        _ uiViewController: WrapInNavigationView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<WrapInNavigationView>
    ) {
    }
}
