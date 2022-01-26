import SwiftUI

struct MapView: UIViewControllerRepresentable {

    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MapView>
    ) -> MapView.UIViewControllerType {
        return UINavigationController(
            rootViewController: MapViewController.createInstance(viewModel: .init())
        )
    }

    func updateUIViewController(
        _ uiViewController: MapView.UIViewControllerType,
        context: UIViewControllerRepresentableContext<MapView>
    ) {
    }
}
