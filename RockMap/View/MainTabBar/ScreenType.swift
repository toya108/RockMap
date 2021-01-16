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
    #if !RELEASE
    case debug
    #endif
    
    var viewController: UIViewController {
        switch self {
        case .rockSearch:
            return RockMapNavigationController(
                rootVC: UIStoryboard(name: RockSearchViewController.className, bundle: nil).instantiateInitialViewController()!,
                naviBarClass: RockMapNavigationBar.self
            )
            
        case .register:
            return RockMapNavigationController(
                rootVC: UIStoryboard(name: RegisterViewController.className, bundle: nil).instantiateInitialViewController()!,
                naviBarClass: RockMapNavigationBar.self
            )

        case .myPage:
            return RockMapNavigationController(
                rootVC: UIStoryboard(name: MyPageViewController.className, bundle: nil).instantiateInitialViewController()!,
                naviBarClass: RockMapNavigationBar.self
            )
            
        #if !RELEASE
        case .debug:
            return DebugViewController()
        #endif
        
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
            
        #if !RELEASE
        case .debug:
            return "debug"
        #endif
        }
    }
    
    var image: UIImage? {
        switch self {
        case .rockSearch:
            let image = UIImage.AssetsImages.map.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .register:
            let image = UIImage.AssetsImages.pencilCircle.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .myPage:
            let image = UIImage.AssetsImages.personCircle.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image

        #if !RELEASE
        case .debug:
            return nil
        #endif
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
        case .rockSearch:
            let image = UIImage.AssetsImages.mapFill.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .register:
            let image = UIImage.AssetsImages.pencilCircleFill.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .myPage:
            let image = UIImage.AssetsImages.personCircleFill.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
        
        #if !RELEASE
        case .debug:
            return nil
        #endif
        }
    }
}
