//
//  UIImageViewExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/01.
//

import UIKit
import FirebaseStorage

extension UIImageView {
    
    func loadImage(
        url: URL?
    ) {
        sd_setImage(
            with: url,
            placeholderImage: UIImage.AssetsImages.noimage
        )
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

        sd_setImage(
            with: reference,
            placeholderImage: UIImage.AssetsImages.noimage
        )
    }
}
