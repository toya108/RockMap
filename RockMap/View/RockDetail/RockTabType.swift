//
//  RockTabType.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/15.
//

import UIKit

enum RockTabType: CaseIterable {
    case map
    case cources
    case climbers
    
    var title: String {
        switch self {
        case .map: return "マップ"
        
        case .cources: return "課題"
        
        case .climbers: return "完登者"
        
        }
    }
    
    var image: UIImage {
        switch self {
        case .map: return UIImage.AssetsImages.map
        
        case .cources: return UIImage.AssetsImages.pencilCircle
        
        case .climbers: return UIImage.AssetsImages.flagCircle
        
        }
    }
    
    var selectingImage: UIImage {
        switch self {
        case .map: return UIImage.AssetsImages.mapFill
        
        case .cources: return UIImage.AssetsImages.pencilCircleFill
        
        case .climbers: return UIImage.AssetsImages.flagCircleFill
        
        }
    }
    
    var viewController: UIViewController {
        switch self {
        case .map: return RockDetailMapViewController()
            
        case .cources: return RockCourcesViewController()
            
        case .climbers: return RockClimbersTableViewController()
        
        }
    }
}
