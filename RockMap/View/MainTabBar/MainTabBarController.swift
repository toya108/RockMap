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
        }
    }
    
    private func setupLayout() {
        UITabBar.appearance().tintColor = UIColor.Pallete.primaryGreen
        
        let borderLineView = UIView()
        borderLineView.backgroundColor = UIColor.Pallete.primaryGreen
        borderLineView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(borderLineView)
        
        NSLayoutConstraint.activate([
            borderLineView.heightAnchor.constraint(equalToConstant: 1),
            borderLineView.leftAnchor.constraint(equalTo: tabBar.leftAnchor),
            borderLineView.rightAnchor.constraint(equalTo: tabBar.rightAnchor)
        ])
    }
}
