
import UIKit
import FirebaseFirestoreSwift

public extension Domain.Entity {

    struct ClimbRecord: EntityProtocol {

        var id: String
        var registeredUserId: String
        var parentCourseId: String
        var parentCourseReference: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType

        public init(
            id: String,
            registeredUserId: String,
            parentCourseId: String,
            parentCourseReference: String,
            createdAt: Date,
            updatedAt: Date?,
            parentPath: String,
            climbedDate: Date,
            type: Domain.Entity.ClimbRecord.ClimbedRecordType
        ) {
            self.id = id
            self.registeredUserId = registeredUserId
            self.parentCourseId = parentCourseId
            self.parentCourseReference = parentCourseReference
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.climbedDate = climbedDate
            self.type = type
        }
    }

}

public extension Domain.Entity.ClimbRecord {

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
