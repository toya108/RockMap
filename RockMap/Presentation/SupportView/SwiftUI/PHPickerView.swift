import Foundation
import SwiftUI
import PhotosUI

struct PHPickerView: UIViewControllerRepresentable {

    @Binding var state: LoadingState<Return>

    private let configuration: PHPickerConfiguration
    private var imageType: Entity.Image.ImageType

    init(
        state: Binding<LoadingState<Return>>,
        configuration: PHPickerConfiguration,
        imageType: Entity.Image.ImageType
    ) {
        self._state = state
        self.configuration = configuration
        self.imageType = imageType
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let viewController = PHPickerViewController(configuration: configuration)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {
    }
}

extension PHPickerView {

    struct Return {
        let data: Data
        let imageType: Entity.Image.ImageType
    }

    class Coordinator: PHPickerViewControllerDelegate {
        let parent: PHPickerView

        init(_ parent: PHPickerView) {
            self.parent = parent
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            picker.dismiss(animated: true)

            if results.isEmpty { return }

            parent.state = .loading

            results.map(\.itemProvider).forEach {

                guard $0.canLoadObject(ofClass: UIImage.self) else { return }

                $0.loadObject(ofClass: UIImage.self) { [weak self] providerReading, error in

                    guard let self = self else { return }

                    if let error = error {
                        self.parent.state = .failure(error)
                        return
                    }

                    guard
                        let image = providerReading as? UIImage,
                        let resizedImage = self.resizeImage(image: image),
                        let data = resizedImage.jpegData(compressionQuality: 1)
                    else {
                        return
                    }

                    DispatchQueue.main.async {
                        self.parent.state = .finish(
                            content: .init(data: data, imageType: self.parent.imageType)
                        )
                    }
                }
            }
        }

        private func resizeImage(
            image: UIImage,
            targetSize: CGSize = CGSize(width: 600, height: 600)
        ) -> UIImage? {
            let size = image.size

            let widthRatio = targetSize.width / image.size.width
            let heightRatio = targetSize.height / image.size.height

            let newSize: CGSize = {
                let size = widthRatio > heightRatio
                ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
                : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
                return size
            }()

            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
    }
}
