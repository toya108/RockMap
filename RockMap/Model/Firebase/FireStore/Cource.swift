//
//  Course.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import Foundation
import UIKit

extension FIDocument {
    struct Course: FIDocumentProtocol {
        typealias Collection = FINameSpace.Course
        
        var id: String = ""
        var name: String = ""
        var desc: String = ""
        var grade: Grade
        var climbedUserIdList: [String]
//        var isPrivate: Bool
        var registedUserId: String
        var registeredDate: Date
        
        enum Grade: String, CaseIterable, Codable {
            case d5, d4, d3, d2, d1, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10
            
            var name: String {
                switch self {
                case .d5:
                    return "5段"
                    
                case .d4:
                    return "4段"
                    
                case .d3:
                    return "3段"
                    
                case .d2:
                    return "2段"
                    
                case .d1:
                    return "初段"
                    
                case .q1:
                    return "1級"
                    
                case .q2:
                    return "2級"
                    
                case .q3:
                    return "3級"
                    
                case .q4:
                    return "4級"
                    
                case .q5:
                    return "5級"
                    
                case .q6:
                    return "6級"
                    
                case .q7:
                    return "7級"
                    
                case .q8:
                    return "8級"
                    
                case .q9:
                    return "9級"
                    
                case .q10:
                    return "10級"
                    
                }
            }
            
            var alpha: CGFloat {
                let index = Self.allCases.firstIndex(of: self)!
                let onceAlpha = 1 / Self.allCases.count
                return CGFloat(index * onceAlpha)
            }
        }
    }
}
