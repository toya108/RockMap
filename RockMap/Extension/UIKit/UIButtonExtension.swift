//
//  UIButtonExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/21.
//

import UIKit

extension UIButton {
    func pop() {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = popAnimations
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animationGroup.sequenceAnimation()
        
        layer.add(animationGroup, forKey: "animation")
    }
    
    private var popAnimations: [CABasicAnimation] {
        return [
            createTransformScaleAnimation(duration: 0.1, fromValue: 1.0, toValue: 0.3),
            createTransformScaleAnimation(duration: 0.1, fromValue: 0.3, toValue: 1.3),
            createTransformScaleAnimation(duration: 0.1, fromValue: 1.3, toValue: 1.0),
            createTransformScaleAnimation(duration: 0.2, fromValue: 1.0, toValue: 1.2),
            createTransformScaleAnimation(duration: 0.1, fromValue: 1.2, toValue: 1.0)
        ]
    }
    
    private func createTransformScaleAnimation(duration: TimeInterval, fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = duration
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        return animation
    }
}

extension CAAnimationGroup {
    func sequenceAnimation() {
        var totalTime = 0.0
        
        animations?.enumerated().forEach { index, element in
            animations?[index].beginTime = totalTime
            totalTime += element.duration
        }
        
        self.duration = totalTime
    }
}
