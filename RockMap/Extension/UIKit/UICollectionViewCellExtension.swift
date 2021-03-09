//
//  UICollectionViewCellExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit

extension UICollectionViewCell {
    
    func executeSelectAnimation() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.alpha = 0.5
            }
        ) { _ in
            UIView.animate(
                withDuration: 0.1,
                animations: {
                    self.alpha = 1
                }
            )
        }
    }
}
