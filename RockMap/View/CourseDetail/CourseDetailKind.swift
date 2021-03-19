//
//  CourseDetailKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case a
        
        var headerTitle: String {
            return ""
        }
        
        var headerIdentifer: String {
            return ""
        }
    }
    
    enum ItemKind: Hashable {
        case a
    }
    
}
