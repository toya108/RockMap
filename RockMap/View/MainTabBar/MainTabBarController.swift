//
//  MainTabBarController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/07.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        setupViewControllers()
        setupTabItem()
        setupLayout()
    }
    
    private func setupViewControllers() {
        setViewControllers(ScreenType.allCases.map(\.viewController), animated: true)
    }
    
    private func setupTabItem() {
        guard let viewControllers = viewControllers else { return }
        
        zip(viewControllers.map(\.tabBarItem), ScreenType.allCases).forEach {
            $0.0?.title = $0.1.tabName
            $0.0?.image = $0.1.image
            $0.0?.selectedImage = $0.1.selectedImage
        }
    }
    
    private func setupLayout() {
        UITabBar.appearance().barTintColor = UIColor.Pallete.primaryGreen
        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().backgroundImage = UIGraphicsImageRenderer.init(size: .init(width: 1, height: 1)).image { context in
            UIColor.Pallete.primaryGreen.setFill()
            context.fill(.init(origin: .init(x: 0, y: 0), size: .init(width: 1, height: 1)))
        }
        UITabBar.appearance().shadowImage = UIImage()
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        tabBar.layer.shadowColor = Resources.Const.UI.Shadow.color
        tabBar.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        tabBar.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        tabBar.layer.shadowOffset = .init(width: 0, height: -2)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard
            viewController.children.first is RegisterViewController
        else {
            return true
        }
        
        let vc = RockMapNavigationController(
            rootVC: UIStoryboard(name: RegisterViewController.className, bundle: nil).instantiateInitialViewController()!,
            naviBarClass: RockMapNavigationBar.self
        )
        vc.modalPresentationStyle = .fullScreen
        tabBarController.present(vc, animated: true)
        return false
    }
}
