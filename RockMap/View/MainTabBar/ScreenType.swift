//
//  ScreenType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import UIKit

// swiftlint:disable force_unwrapping

enum ScreenType: CaseIterable {
    case rockSearch
    case register
    case myPage
    
    var viewController: UIViewController {
        switch self {
        case .rockSearch:
            return UINavigationController(rootViewController: UIStoryboard(name: RockSearchViewController.className, bundle: nil).instantiateInitialViewController()!)
            
        case .register:
            return UINavigationController(rootViewController: UIStoryboard(name: RegisterViewController.className, bundle: nil).instantiateInitialViewController()!)
            
        case .myPage:
            return UINavigationController(rootViewController: UIStoryboard(name: MyPageViewController.className, bundle: nil).instantiateInitialViewController()!)
            
        }
    }
    
    var tabName: String {
        switch self {
        case .rockSearch:
            return "岩を探す"
            
        case .register:
            return "課題を作る"
            
        case .myPage:
            return "マイページ"
            
        }
    }
    
    var image: UIImage? {
        switch self {
        case .rockSearch:
            return UIImage.AssetsImages.mapFill
            
        case .register:
            return UIImage.AssetsImages.pencilCircle
            
        case .myPage:
            return UIImage.AssetsImages.personCircle
            
//        #if !RELEASE
//        case .debug:
//            return nil
//        #endif
        }
    }
}
