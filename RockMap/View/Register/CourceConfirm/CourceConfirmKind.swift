//
//  CourceConfirmKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Foundation

extension CourseConfirmViewController {
    
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
                return "課題を登録する岩"
                
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
    }
    
    enum ItemKind: Hashable {
        case rock(CourceRegisterViewModel.RockHeaderStructure)
        case courceName(String)
        case grade(FIDocument.Cource.Grade)
        case images(IdentifiableData)
        case desc(String)
        case makePrivate
        case confirmation
    }
    
}
