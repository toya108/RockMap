//
//  UIImageViewExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/01.
//

import UIKit
import SDWebImage
import FirebaseStorage

extension UIImageView {
    
    func loadImage(
        url: URL?
    ) {
        sd_imageIndicator = SDWebImageActivityIndicator.gray
        sd_setImage(with: url) { [weak self] _, error, _, _ in
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
    
    func loadImage(
        reference: StorageReference?
    ) {
        guard
            let reference = reference
        else {
            image = UIImage.AssetsImages.noimage
            return
        }

        sd_imageIndicator = SDWebImageActivityIndicator.gray
        sd_setImage(with: reference, placeholderImage: nil) { [weak self] _, error, _, _ in
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
