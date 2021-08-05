//
//  Climbed.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

import UIKit
import FirebaseFirestoreSwift

extension FIDocument {

    struct ClimbRecord: FIDocumentProtocol, UserRegisterableDocumentProtocol {
        
        typealias Collection = FINameSpace.ClimbRecord
        
        var id: String = UUID().uuidString
        var registeredUserId: String
        var parentCourseId: String
        var parentCourseReference: DocumentRef
        var totalNumberReference: DocumentRef
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType
    }

}

extension FIDocument.ClimbRecord {

    enum ClimbedRecordType: String, CaseIterable, Codable {
        case flash, redPoint

        var name: String {
            switch self {
                case .flash:
                    return "Flash"
                    
                case .redPoint:
                    return "RedPoint"
                    
            }
        }

        var fieldName: String {
            switch self {
                case .flash:
                    return "flashTotal"

                case .redPoint:
                    return "redPointTotal"

            }
        }

        var isFlash: Bool {
            self == .flash
        }

        var isRedpoint: Bool {
            self == .redPoint
        }
    }
}
