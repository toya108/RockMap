//
//  File.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit
import CoreLocation

extension RockRegisterViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case name
        case desc
        case location
        case season
        case lithology
        case header
        case images
        case confirmation
        
        var headerTitle: String {
            switch self {
            case .name:
                return "岩名"
                
            case .desc:
                return "詳細"
                
            case .location:
                return "住所"
                
            case .season:
                return "シーズン"
                
            case .lithology:
                return "岩質"

            case .header:
                return "ヘッダー画像"
                
            case .images:
                return "それ以外の画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .name, .desc, .location, .season, .lithology, .images, .header:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
        
        var initialItems: [ItemKind] {
            switch self {
            case .name:
                return [.name]
                
            case .desc:
                return [.desc]

            case .header:
                return [.noImage(.header)]

            case .images:
                return [.noImage(.normal)]
                
            case .confirmation:
                return [.confirmation]
                
            default:
                return []
            }
        }
    }
    
    enum ItemKind: Hashable {
        case name
        case desc
        case location(LocationManager.LocationStructure)
        case season(season: Entity.Rock.Season, isSelecting: Bool)
        case lithology(Entity.Rock.Lithology)
        case noImage(Entity.Image.ImageType)
        case header(CrudableImageV2)
        case images(CrudableImageV2)
        case confirmation
        case error(ValidationError)
        
        var isErrorItem: Bool {
            if case .error = self {
                return true
                
            } else {
                return false
                
            }
        }
    }
    
}
