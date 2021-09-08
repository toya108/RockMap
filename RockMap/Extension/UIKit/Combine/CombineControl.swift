import Combine
import UIKit

public extension Combine.Publishers {
    struct ControlProperty<Control: UIControl, Value>: Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        private let control: Control
        private let controlEvents: Control.Event
        private let keyPath: KeyPath<Control, Value>

        public init(
            control: Control,
            events: Control.Event,
            keyPath: KeyPath<Control, Value>
        ) {
            self.control = control
            self.controlEvents = events
            self.keyPath = keyPath
        }

        public func receive<S: Subscriber>(
            subscriber: S
        ) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(
                subscriber: subscriber,
                control: control,
                event: controlEvents,
                keyPath: keyPath
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Combine.Publishers.ControlProperty {
    private final class Subscription<S: Subscriber, Control: UIControl, Value>: Combine
        .Subscription where S.Input == Value
    {
        private var subscriber: S?
        private weak var control: Control?

        let keyPath: KeyPath<Control, Value>
        private var didEmitInitial = false
        private let event: Control.Event

        init(
            subscriber: S,
            control: Control,
            event: Control.Event,
            keyPath: KeyPath<Control, Value>
        ) {
            self.subscriber = subscriber
            self.control = control
            self.keyPath = keyPath
            self.event = event
            control.addTarget(self, action: #selector(self.handleEvent), for: event)
        }

        func request(
            _ demand: Subscribers.Demand
        ) {
            if
                !self.didEmitInitial,
                demand > .none,
                let control = control,
                let subscriber = subscriber
            {
                _ = subscriber.receive(control[keyPath: self.keyPath])
                self.didEmitInitial = true
            }
        }

        func cancel() {
            self.control?.removeTarget(self, action: #selector(self.handleEvent), for: self.event)
            self.subscriber = nil
        }

        @objc private func handleEvent() {
            guard let control = control else { return }
            _ = self.subscriber?.receive(control[keyPath: self.keyPath])
        }
    }
}

extension UIControl.Event {
    static var defaultValueEvents: UIControl.Event {
        [.allEditingEvents, .valueChanged]
    }
}
