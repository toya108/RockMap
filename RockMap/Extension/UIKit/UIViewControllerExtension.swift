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
    
    var tabBarHeight: CGFloat {
        guard let rootTabVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController else { return 0.0 }
        return rootTabVC.tabBar.bounds.height
    }
}
