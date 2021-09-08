import Combine
import UIKit

extension UIResponder {
    static var keyboardInfoPublisher: AnyPublisher<KeyboardInfo, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo as? [String: Any] }
            .compactMap { info -> KeyboardInfo? in

                guard
                    let duration =
                    info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                    let height = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                        .cgRectValue else { return nil }

                return .init(duration: duration, rect: height)
            }
            .eraseToAnyPublisher()
    }

    static var keyboardHidePublisher: AnyPublisher<Double, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { $0.userInfo as? [String: Any] }
            .compactMap { $0[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double }
            .eraseToAnyPublisher()
    }

    struct KeyboardInfo {
        var duration: Double
        var rect: CGRect
    }
}
