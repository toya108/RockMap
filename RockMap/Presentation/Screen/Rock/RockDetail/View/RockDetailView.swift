import SwiftUI

struct RockDetailView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    let rock: Entity.Rock

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<RockDetailView>
    ) -> RockDetailView.UIViewControllerType {
        return UINavigationController(
            rootViewController: RockDetailViewController.createInstance(
                viewModel: .init(rock: rock)
            )
        )
    }

    func updateUIViewController(
        _ uiViewController: RockDetailView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<RockDetailView>
    ) {}
}
