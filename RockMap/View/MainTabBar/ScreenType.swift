//
//  ScreenType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import UIKit

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
    
//    var image: UIImage? {
//        switch self {
//        case .top:
//            return R.image.iconNavTopOff()
//
//        case .timeLine:
//            return R.image.iconNavScheduleOff()
//
//        case .programList:
//            // バッジの有無によって画像が変わるので、直接設定する
//            return nil
//
//        case .mypage:
//            return R.image.iconNavMypageOff()
//
//        #if !RELEASE
//        case .debug:
//            return nil
//        #endif
//
//        }
//    }
}
