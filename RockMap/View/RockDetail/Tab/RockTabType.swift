//
//  RockTabType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/15.
//

import UIKit

enum RockTabType: CaseIterable {
    case mappin
    case cources
    case climbers
    
    var title: String {
        switch self {
        case .mappin: return "場所"
        
        case .cources: return "課題"
        
        case .climbers: return "完登者"
        
        }
    }
    
    var image: UIImage {
        switch self {
        case .mappin: return UIImage.AssetsImages.mappinCircle
        
        case .cources: return UIImage.AssetsImages.pencilCircle
        
        case .climbers: return UIImage.AssetsImages.flagCircle
        
        }
    }
    
    var selectingImage: UIImage {
        switch self {
        case .mappin: return UIImage.AssetsImages.mappinCircleFill
        
        case .cources: return UIImage.AssetsImages.pencilCircleFill
        
        case .climbers: return UIImage.AssetsImages.flagCircleFill
        
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .mappin:
            return UIStoryboard(name: RockDetailMapViewController.className, bundle: nil).instantiateInitialViewController()!
            
        case .cources: return RockCourcesViewController()
            
        case .climbers: return RockClimbersTableViewController()
        
        }
    }
}
