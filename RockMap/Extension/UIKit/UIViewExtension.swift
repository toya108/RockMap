//
//  UIViewExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/02.
//

import UIKit


extension UIView {
    func fadeIn(duration: TimeInterval) {
        isHidden = false
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = 1.0
            }
        )
    }
    
    func fadeOut(duration: TimeInterval) {
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self = self else { return }
                
                self.alpha = 0.0
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                
                self.isHidden = true
            }
        )
    }
}

