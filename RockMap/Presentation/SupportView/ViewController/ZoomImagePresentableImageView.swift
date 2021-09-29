import UIKit

@IBDesignable
class ZoomImagePresentableImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.presentZoomImageViewController)
        )
        addGestureRecognizer(gesture)
    }

    @objc private func presentZoomImageViewController() {
        root?.present(
            ZoomImageViewController.createInstance(
                images: [self.image ?? UIImage.AssetsImages.noimage],
                currentIndex: 0
            ),
            animated: true
        )
    }
}
