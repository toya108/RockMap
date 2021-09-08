import FirebaseStorage
import SDWebImage
import UIKit

extension UIImageView {
    func loadImage(
        url: URL?
    ) {
        sd_imageIndicator = SDWebImageActivityIndicator.gray
        sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [.refreshCached]
        ) { [weak self] _, error, _, _ in
            guard
                let self = self,
                let error = error
            else {
                return
            }

            print(error.localizedDescription)
            self.image = UIImage.AssetsImages.noimage
        }
    }
}

extension UIButton {
    func loadImage(
        url: URL?
    ) {
        sd_imageIndicator = SDWebImageActivityIndicator.gray
        sd_setBackgroundImage(
            with: url,
            for: .normal,
            placeholderImage: nil,
            options: [.refreshCached]
        ) { [weak self] _, error, _, _ in
            guard
                let self = self,
                let error = error
            else {
                return
            }

            print(error.localizedDescription)
            self.setImage(UIImage.AssetsImages.noimage, for: .normal)
        }
    }
}
