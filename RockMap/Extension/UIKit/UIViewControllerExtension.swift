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
    
    func topViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
    
    func showOKAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
