//
//  ZoomImageViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/05.
//

import UIKit

final class ZoomImageViewController: UIViewController {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageStackView: UIStackView!

    private var images: [UIImage] = []
    private var currentIndex: Int = 0
    private var needsOffsetCorrect = false

    private var currentImageView: UIImageView? {
        imageStackView.arrangedSubviews.any(at: currentIndex) as? UIImageView
    }

    private var isZooming: Bool {
        imageScrollView.zoomScale != 1.0
    }

    private var isZoomingMode: Bool {
        !imageStackView.arrangedSubviews.allSatisfy { !$0.isHidden }
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

        imageScrollView.delegate = self

        imageStackView.arrangedSubviews.forEach {
            imageStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        images.forEach {
            let imageView = UIImageView(image: $0)
            imageView.contentMode = .scaleAspectFit
            imageStackView.addArrangedSubview(imageView)
            imageView.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isZoomingMode {
            imageScrollView.contentOffset = .init(
                x: imageScrollView.bounds.size.width * CGFloat(currentIndex),
                y: 0
            )
            return
        }

        if needsOffsetCorrect {
            let beforeWidth = imageScrollView.bounds.size.width * CGFloat(currentIndex) * imageScrollView.zoomScale
            imageScrollView.contentOffset = .init(
                x: imageScrollView.contentOffset.x - beforeWidth,
                y: imageScrollView.contentOffset.y
            )
            needsOffsetCorrect = false
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomImageViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        guard !isZooming, !isZoomingMode else { return }

        currentIndex = Int(imageScrollView.contentOffset.x / imageScrollView.frame.width)
    }

    func viewForZooming(
        in scrollView: UIScrollView
    ) -> UIView? {
        imageStackView
    }

    func scrollViewDidZoom(
        _ scrollView: UIScrollView
    ) {
        if isZoomingMode { updateArrangeViews() }
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat
    ) {
        updateArrangeViews()
    }

    private func updateArrangeViews() {

        needsOffsetCorrect = imageScrollView.isPagingEnabled && isZooming
        imageScrollView.isPagingEnabled = !isZooming
        UIView.performWithoutAnimation {
            imageStackView.arrangedSubviews
                .filter { $0 != currentImageView }
                .forEach { $0.isHidden = isZooming }
            view.layoutIfNeeded()
        }
    }

    private func updateContentInset() {

        guard
            imageScrollView.zoomScale > 1
        else {
            imageScrollView.contentInset = UIEdgeInsets.zero
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
            newWidth * imageScrollView.zoomScale > imageView.frame.width
                ? (newWidth - imageView.frame.width)
                : (imageScrollView.frame.width - imageScrollView.contentSize.width)
        )
        let top = 0.5 * (
            newHeight * imageScrollView.zoomScale > imageView.frame.height
                ? (newHeight - imageView.frame.height)
                : (imageScrollView.frame.height - imageScrollView.contentSize.height)
        )

        imageScrollView.contentInset = .init(top: top, left: left, bottom: top, right: left)
    }
}

