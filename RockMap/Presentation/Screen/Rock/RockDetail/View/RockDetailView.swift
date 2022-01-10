import SwiftUI

struct RockDetailView: UIViewControllerRepresentable {

    typealias UIViewControllerType = RockDetailViewController

    let rock: Entity.Rock

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<RockDetailView>
    ) -> RockDetailView.UIViewControllerType {
        RockDetailViewController.createInstance(
            viewModel: .init(rock: rock)
        )
    }

    func updateUIViewController(
        _ uiViewController: RockDetailView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<RockDetailView>
    ) {}
}
