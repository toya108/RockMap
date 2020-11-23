//
//  HeaderIgnorableScrollView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import UIKit

final class HeaderIgnorableScrollView: UIScrollView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if view == self,
           point.x < UIScreen.main.bounds.width && point.y < UIScreen.main.bounds.height * (9/16) {
            return nil
        }
        return view
    }
}
