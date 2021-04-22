//
//  Climbed.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

import UIKit

extension FIDocument {
    struct Climbed: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Climbed
        
        var id: String = UUID().uuidString
        var parentCourseReference: DocumentRef
        var totalNumberReference: DocumentRef
        var createdAt: Date = Date()
        var updatedAt: Date? = nil
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType
        var climbedUserId: String
        
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

            var color: UIColor {
                switch self {
                    case .flash:
                        return UIColor.Pallete.primaryGreen

                    case .redpoint:
                        return UIColor.Pallete.primaryPink

                }
            }

            var isFlash: Bool {
                self == .flash
            }

            var isRedpoint: Bool {
                self == .redpoint
            }
        }
    }
}
