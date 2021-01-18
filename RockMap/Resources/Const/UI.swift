//
//  UIConst.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/29.
//

import UIKit

extension Resources.Const {
    struct UI {}
}

extension Resources.Const.UI {
    struct View {
        static let radius: CGFloat = 8
    }
    
    struct Shadow {
        static let radius: CGFloat = 8
        static let color = UIColor.gray.cgColor
        static let opacity: Float = 0.5
    }
}
