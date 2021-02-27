//
//  CourceRegisterKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

extension CourceRegisterViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case rock
        case courceName
        case desc
        case grade
        case images
        case makePrivate
        case confirmation
        
        var headerTitle: String {
            switch self {
            case .rock:
                return "登録する岩"
                
            case .courceName:
                return "課題名"
                
            case .desc:
                return "課題詳細"
                
            case .grade:
                return "グレード"
                
            case .images:
                return "画像をアップロード"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .rock, .courceName, .grade, .images, .desc:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
        
        var initalItems: [ItemKind] {
            switch self {
            case .courceName:
                return [.courceName]
                
            case .desc:
                return [.desc]
                
            case .grade:
                return FIDocument.Cource.Grade.allCases.map { ItemKind.grade($0) }
            
            case .images:
                return [.noImage]
                
            case .confirmation:
                return [.confirmation]
                
            default:
                return []
            }
        }
    }
    
    enum ItemKind: Hashable {
        case rock(CourceRegisterViewModel.RockHeaderStructure)
        case courceName
        case grade(FIDocument.Cource.Grade)
        case noImage
        case images(IdentifiableData)
        case desc
        case makePrivate
        case confirmation
        case error(String)
        
        var isErrorItem: Bool {
            if case .error = self {
                return true
                
            } else {
                return false
                
            }
        }
    }
    
}
