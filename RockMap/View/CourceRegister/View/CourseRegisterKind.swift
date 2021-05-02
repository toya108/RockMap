//
//  courseRegisterKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

extension CourseRegisterViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case rock
        case courseName
        case desc
        case grade
        case shape
        case header
        case images
        case confirmation
        
        var headerTitle: String {
            switch self {
            case .rock:
                return "登録する岩"
                
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
            case .rock, .courseName, .grade, .shape, .header, .images, .desc:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
        
        var initalItems: [ItemKind] {
            switch self {
            case .courseName:
                return [.courseName]
                
            case .desc:
                return [.desc]
                
            case .grade:
                return [.grade(.q10)]

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
        case rock
        case courseName
        case grade(FIDocument.Course.Grade)
        case shape(shape: FIDocument.Course.Shape, isSelecting: Bool)
        case noImage(ImageType)
        case header(IdentifiableData)
        case images(IdentifiableData)
        case desc
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
