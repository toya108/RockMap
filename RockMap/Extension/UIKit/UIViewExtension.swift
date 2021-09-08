import UIKit
import Utilities

extension UIView {
    func fadeIn(duration: TimeInterval) {
        isHidden = false
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self = self else { return }

                self.alpha = 1.0
            }
        )
    }

    func fadeOut(duration: TimeInterval) {
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self = self else { return }

                self.alpha = 0.0
            },
            completion: { [weak self] _ in
                guard let self = self else { return }

                self.isHidden = true
            }
        )
    }

    func addShadow() {
        layer.shadowRadius = Resources.Const.UI.Shadow.radius
        layer.shadowOpacity = 0.3
    }
}

extension NSLayoutConstraint {
    static func build(
        @ListBuilder<NSLayoutConstraint> builder: () -> [NSLayoutConstraint]
    ) {
        Self.activate(builder())
    }
}
