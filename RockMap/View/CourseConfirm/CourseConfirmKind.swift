//
//  courseConfirmKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Foundation

extension CourseConfirmViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case rock
        case courseName
        case desc
        case grade
        case shape
        case images
        case register
        
        var headerTitle: String {
            switch self {
            case .rock:
                return "課題を登録する岩"
                
            case .courseName:
                return "課題名"
                
            case .desc:
                return "課題詳細"
                
            case .grade:
                return "グレード"
                
            case .shape:
                return "形状"
                
            case .images:
                return "画像をアップロード"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .rock, .courseName, .grade, .images, .shape, .desc:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
    }
    
    enum ItemKind: Hashable {
        case rock(CourseRegisterViewModel.RockHeaderStructure)
        case courseName(String)
        case desc(String)
        case grade(FIDocument.Course.Grade)
        case shape(Set<FIDocument.Course.Shape>)
        case images(IdentifiableData)
        case register
    }
    
}
