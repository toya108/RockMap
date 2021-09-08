import UIKit

class RegisterSucceededViewController: UIViewController {
    static func showSuccessView(
        present from: UIViewController,
        completion: @escaping () -> Void
    ) {
        guard
            let vc = UIStoryboard(
                name: RegisterSucceededViewController.className,
                bundle: nil
            ).instantiateInitialViewController()
        else {
            return
        }

        guard
            let delegate = from as? UIPopoverPresentationControllerDelegate
        else {
            assertionFailure()
            return
        }

        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = from.view
        vc.popoverPresentationController?
            .permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        vc.popoverPresentationController?.delegate = delegate
        vc.popoverPresentationController?.sourceRect = .init(
            origin: .init(
                x: UIScreen.main.bounds.midX,
                y: UIScreen.main.bounds.midY
            ),
            size: .zero
        )

        from.present(vc, animated: true, completion: completion)
    }
}

extension RegisterSucceededViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController
    ) -> Bool {
        false
    }
}
