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
        case grade
        case images
        case desc
        case makePrivate
        
        var headerTitle: String {
            switch self {
            case .rock:
                return "登録する岩"
                
            case .courceName:
                return "課題名"
                
            case .grade:
                return "グレード"
                
            case .images:
                return "画像をアップロード"
            
            case .desc:
                return "課題詳細"
                
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
    }
    
    enum ItemKind: Hashable {
        case rock(CourceRegisterViewModel.RockHeaderStructure)
        case courceName
        case grade(FIDocument.Cource.Grade)
        case noImage
        case images(IdentifiableData)
        case desc
        case makePrivate
    }
    
}
