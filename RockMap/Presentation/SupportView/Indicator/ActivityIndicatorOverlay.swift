import UIKit

private let overlayViewTag: Int = 999
private let activityIndicatorViewTag: Int = 1000

extension UIView {
    func showIndicatorView() {
        setActivityIndicatorView()
    }

    func hideIndicatorView() {
        removeActivityIndicatorView()
    }
}

extension UIViewController {
    private var overlayContainerView: UIView {
        if let navigationView: UIView = navigationController?.view {
            return navigationView
        }
        return view
    }

    func showIndicatorView() {
        self.overlayContainerView.showIndicatorView()
    }

    func hideIndicatorView() {
        self.overlayContainerView.hideIndicatorView()
    }
}

extension UIView {
    private var activityIndicatorView: UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView()
        indicator.color = .systemGroupedBackground
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.tag = activityIndicatorViewTag
        return indicator
    }

    private var overlayView: UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.4
        view.tag = overlayViewTag
        return view
    }

    private func setActivityIndicatorView() {
        guard !self.isDisplayingActivityIndicatorOverlay() else { return }
        let overlayView = self.overlayView
        let activityIndicatorView = self.activityIndicatorView

        overlayView.addSubview(activityIndicatorView)
        addSubview(overlayView)

        overlayView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        overlayView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

        activityIndicatorView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
            .isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor)
            .isActive = true

        activityIndicatorView.startAnimating()
    }

    private func removeActivityIndicatorView() {
        guard
            let overlayView = getOverlayView(),
            let activityIndicator = getActivityIndicatorView()
        else {
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: {
                overlayView.alpha = 0.0
                activityIndicator.stopAnimating()
            }
        ) { _ in
            activityIndicator.removeFromSuperview()
            overlayView.removeFromSuperview()
        }
    }

    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        self.getActivityIndicatorView() != nil && self.getOverlayView() != nil
    }

    private func getActivityIndicatorView() -> UIActivityIndicatorView? {
        viewWithTag(activityIndicatorViewTag) as? UIActivityIndicatorView
    }

    private func getOverlayView() -> UIView? {
        viewWithTag(overlayViewTag)
    }
}
