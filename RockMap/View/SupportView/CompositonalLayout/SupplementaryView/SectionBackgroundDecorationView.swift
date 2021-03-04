//
//  SectionBackgroundDecorationView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/22.
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .white
    }
}
