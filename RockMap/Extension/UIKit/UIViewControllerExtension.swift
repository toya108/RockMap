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
    
    func getVisibleViewController() -> UIViewController? {
        guard
            let rootViewController = rootViewController
        else {
            return nil
        }
        
        return getVisibleViewController(rootViewController)
    }
    
    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                
                let visible = navigationController.visibleViewController
                
                if visible is UISearchController || visible is UIAlertController {
                    return visible?.presentingViewController ?? visible?.parent
                }
                
                return visible
            }
            return tabBarController.selectedViewController
        }
        
        return rootViewController
    }

    var rootViewController: UIViewController? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
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
    
    func showOKAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showYseOrNoAlert(
        title: String,
        message: String,
        positiveHandler: ((UIAlertAction) -> Void)?,
        negativeHandler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: negativeHandler)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: positiveHandler)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
