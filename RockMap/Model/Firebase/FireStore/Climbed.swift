//
//  Climbed.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

import Foundation

extension FIDocument {
    struct Climbed: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Climbed
        
        var id: String
        var parentCourseId: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType
        var climbedUserId: String
//        var isPrivate: Bool
        
        enum ClimbedRecordType: String, CaseIterable, Codable {
            case flash, redpoint
            
            var name: String {
                switch self {
                case .flash:
                    return "Flash"
                    
                case .redpoint:
                    return "RedPoint"
                    
                }
            }

            var fieldName: String {
                switch self {
                    case .flash:
                        return "flashTotal"

                    case .redpoint:
                        return "redPointTotal"

                }
            }
        }
    }
}
