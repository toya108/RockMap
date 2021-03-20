//
//  CourseDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case headerImages
        case registeredUser
        
        var headerTitle: String {
            return ""
        }
        
        var headerIdentifer: String {
            return ""
        }
    }
    
    enum ItemKind: Hashable {
        case headerImages(StorageManager.Reference)
        case registeredUser(CourseDetailViewModel.UserCellStructure)
    }
    
}
