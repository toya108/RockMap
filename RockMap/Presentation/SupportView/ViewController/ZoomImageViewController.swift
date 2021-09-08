import UIKit

final class ZoomImageViewController: UIViewController {
    @IBOutlet var imageScrollView: UIScrollView!
    @IBOutlet var imageStackView: UIStackView!

    private var images: [UIImage] = []
    private var currentIndex: Int = 0
    private var needsOffsetCorrect = false

    private var currentImageView: UIImageView? {
        self.imageStackView.arrangedSubviews.any(at: self.currentIndex) as? UIImageView
    }

    private var isZooming: Bool {
        self.imageScrollView.zoomScale != 1.0
    }

    private var isZoomingMode: Bool {
        !self.imageStackView.arrangedSubviews.allSatisfy { !$0.isHidden }
    }

    @IBAction func onTouchCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }

    static func createInstance(
        images: [UIImage],
        currentIndex: Int
    ) -> Self {
        let instance = UIStoryboard(
            name: Self.className,
            bundle: nil
        ).instantiateInitialViewController() as! Self

        instance.modalPresentationStyle = .fullScreen
        instance.modalTransitionStyle = .crossDissolve
        instance.images = images
        instance.currentIndex = currentIndex
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageScrollView.delegate = self

        self.imageStackView.arrangedSubviews.forEach {
            imageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        self.images.forEach {
            let imageView = UIImageView(image: $0)
            imageView.contentMode = .scaleAspectFit
            imageStackView.addArrangedSubview(imageView)
            imageView.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor)
                .isActive = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !self.isZoomingMode {
            self.imageScrollView.contentOffset = .init(
                x: self.imageScrollView.bounds.size.width * CGFloat(self.currentIndex),
                y: 0
            )
            return
        }

        if self.needsOffsetCorrect {
            let beforeWidth = self.imageScrollView.bounds.size
                .width * CGFloat(self.currentIndex) * self.imageScrollView.zoomScale
            self.imageScrollView.contentOffset = .init(
                x: self.imageScrollView.contentOffset.x - beforeWidth,
                y: self.imageScrollView.contentOffset.y
            )
            self.needsOffsetCorrect = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomImageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        guard !self.isZooming, !self.isZoomingMode else { return }

        self
            .currentIndex = Int(
                self.imageScrollView.contentOffset.x / self.imageScrollView.frame
                    .width
            )
    }

    func viewForZooming(
        in scrollView: UIScrollView
    ) -> UIView? {
        self.imageStackView
    }

    func scrollViewDidZoom(
        _ scrollView: UIScrollView
    ) {
        if self.isZoomingMode { self.updateArrangeViews() }
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        self.updateArrangeViews()
    }

    private func updateArrangeViews() {
        self.needsOffsetCorrect = self.imageScrollView.isPagingEnabled && self.isZooming
        self.imageScrollView.isPagingEnabled = !self.isZooming
        UIView.performWithoutAnimation {
            imageStackView.arrangedSubviews
                .filter { $0 != currentImageView }
                .forEach { $0.isHidden = isZooming }
            view.layoutIfNeeded()
        }
    }

    private func updateContentInset() {
        guard
            self.imageScrollView.zoomScale > 1
        else {
            self.imageScrollView.contentInset = UIEdgeInsets.zero
            return
        }
        guard
            let imageView = currentImageView,
            let image = imageView.image
        else {
            return
        }

        let ratioW = imageView.frame.width / image.size.width
        let ratioH = imageView.frame.height / image.size.height
        let ratio = ratioW < ratioH ? ratioW : ratioH

        let newWidth = image.size.width * ratio
        let newHeight = image.size.height * ratio

        let left = 0.5 * (
            newWidth * self.imageScrollView.zoomScale > imageView.frame.width
                ? (newWidth - imageView.frame.width)
                : (self.imageScrollView.frame.width - self.imageScrollView.contentSize.width)
        )
        let top = 0.5 * (
            newHeight * self.imageScrollView.zoomScale > imageView.frame.height
                ? (newHeight - imageView.frame.height)
                : (self.imageScrollView.frame.height - self.imageScrollView.contentSize.height)
        )

        self.imageScrollView.contentInset = .init(top: top, left: left, bottom: top, right: left)
    }
}
