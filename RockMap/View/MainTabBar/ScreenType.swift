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
    case myPage
    #if !RELEASE
    case debug
    #endif
    
    var viewController: UIViewController {
        switch self {
        case .rockSearch:
            return RockMapNavigationController(
                rootVC: RockSearchViewController.createInstance(viewModel: .init()),
                naviBarClass: RockMapNavigationBar.self
            )

        case .myPage:
            return RockMapNavigationController(
                rootVC: MyPageViewController.createInstance(viewModel: .init(user: nil)),
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
            let image = UIImage.SystemImages.map.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .myPage:
            let image = UIImage.SystemImages.personCircle.withTintColor(.white, renderingMode: .alwaysOriginal)
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
            let image = UIImage.SystemImages.mapFill.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
            
        case .myPage:
            let image = UIImage.SystemImages.personCircleFill.withTintColor(.white, renderingMode: .alwaysOriginal)
            return image
        
        #if !RELEASE
        case .debug:
            return nil
        #endif
        }
    }
}
