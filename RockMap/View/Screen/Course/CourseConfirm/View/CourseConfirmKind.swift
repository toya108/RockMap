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
        case header
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

            case .header:
                return "ヘッダー画像"
                
            case .images:
                return "その他の画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .rock, .courseName, .grade, .header, .images, .shape, .desc:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
    }
    
    enum ItemKind: Hashable {
        case rock(rockName: String, headerUrl: URL?)
        case courseName(String)
        case desc(String)
        case grade(FIDocument.Course.Grade)
        case shape(Set<FIDocument.Course.Shape>)
        case header(CrudableImage)
        case images(CrudableImage)
        case register
    }
    
}
