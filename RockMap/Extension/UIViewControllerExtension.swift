//
//  UIViewControllerExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/04.
//

import UIKit

extension UIViewController {
    func getFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        return view.subviews.lazy.compactMap {
            return self.getFirstResponder(view: $0)
        }.first
    }
}
