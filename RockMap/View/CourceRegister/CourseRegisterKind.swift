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
        case images
//        case makePrivate
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
                
            case .images:
                return "画像をアップロード"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .rock, .courseName, .grade, .shape, .images, .desc:
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
        case rock(CourseRegisterViewModel.RockHeaderStructure)
        case courseName
        case grade(FIDocument.Course.Grade)
        case shape(shape: FIDocument.Course.Shape, isSelecting: Bool)
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
