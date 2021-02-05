//
//  HorizontalImageListCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/03.
//

import UIKit

class HorizontalImageListCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
    }
    
}
