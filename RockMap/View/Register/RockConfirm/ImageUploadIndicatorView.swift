//
//  ImageUploadIndicatorView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/21.
//

import UIKit

class ImageUploadIndicatorView: UIView {
    
    let total: Int = 0
    let current: Int = 0
    
    init(parentView: UIView, total: Int, current: Int) {
        super.init(frame: parentView.frame)
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0.3
        backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
