//
//  UIImageViewExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/01.
//

import UIKit
import Nuke

extension UIImageView {
    
    func loadImage(url: URL?) {
        
        guard
            let url = url
        else {
            self.image = UIImage.AssetsImages.noimage
            return
        }
        
        let options = ImageLoadingOptions(
            placeholder: UIImage.AssetsImages.noimage,
            failureImage: UIImage.AssetsImages.noimage,
            contentModes: .init(success: .scaleAspectFill, failure: .center, placeholder: .center)
        )
        
        Nuke.loadImage(with: url, options: options, into: self)
    }
}
