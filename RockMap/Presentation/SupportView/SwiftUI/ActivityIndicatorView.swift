import SwiftUI

struct ActivityIndicatorView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            ActivityIndicatorRepresentable()
        }
    }
}

private struct ActivityIndicatorRepresentable: UIViewRepresentable {
    func makeUIView(
        context: UIViewRepresentableContext<ActivityIndicatorRepresentable>
    ) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.color = .white
        return indicator
    }

    func updateUIView(
        _ uiView: UIActivityIndicatorView,
        context: UIViewRepresentableContext<ActivityIndicatorRepresentable>
    ) {
        uiView.startAnimating()
    }
}
