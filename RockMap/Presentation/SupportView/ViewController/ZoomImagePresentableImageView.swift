//
//  ZoomImagePresentableImageView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/05.
//

import UIKit

@IBDesignable
class ZoomImagePresentableImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentZoomImageViewController))
        addGestureRecognizer(gesture)
    }

    @objc private func presentZoomImageViewController() {
        let rootVc = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController

        rootVc?.present(
            ZoomImageViewController.createInstance(
                images: [self.image ?? UIImage.AssetsImages.noimage],
                currentIndex: 0
            ),
            animated: true
        )
    }
}
