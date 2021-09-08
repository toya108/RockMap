import Combine
import UIKit

public extension UISegmentedControl {
    var selectedSegmentIndexPublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(
            control: self,
            events: .defaultValueEvents,
            keyPath: \.selectedSegmentIndex
        )
        .eraseToAnyPublisher()
    }
}
