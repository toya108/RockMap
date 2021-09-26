import UIKit

extension UIControl {

    func addActionForOnce(
        _ action: UIAction,
        for controlEvents: UIControl.Event
    ) {

        guard self.allControlEvents.isEmpty else { return }

        self.addAction(action, for: controlEvents)
    }
    
}
