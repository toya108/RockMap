import Combine
import UIKit

extension UITextView {
    var textDidChangedPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextView }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func setText(text: String) {
        self.text = text
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: self)
    }
}
