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

        guard let rockSearch = UIStoryboard(name: "RockSearchViewController", bundle: nil).instantiateInitialViewController() else { return }
        let rockSearchViewController = UINavigationController(rootViewController: rockSearch)
        let viewControllers = [rockSearchViewController]
        
        setViewControllers(viewControllers, animated: true)
    }
}
