import Combine
import UIKit

public extension UIDatePicker {
    var datePublisher: AnyPublisher<Date, Never> {
        Publishers
            .ControlProperty(
                control: self,
                events: .defaultValueEvents,
                keyPath: \.date
            )
            .eraseToAnyPublisher()
    }
}
