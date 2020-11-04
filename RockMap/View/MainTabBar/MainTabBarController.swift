//
//  MainTabBarController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/07.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabItem()
    }
    
    private func setupTabItem() {
        guard let viewControllers = viewControllers else { return }
        
        zip(viewControllers, ScreenType.allCases).forEach {
            $0.0.title = $0.1.tabName
        }
    }
    
    private func setupViewControllers() {
        setViewControllers(ScreenType.allCases.map { $0.viewController }, animated: true)
    }
}
