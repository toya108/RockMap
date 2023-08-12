import FirebaseFirestoreSwift
import UIKit

public extension Domain.Entity {
    struct ClimbRecord: AnyEntity {
        public var id: String
        public var registeredUserId: String
        public var parentCourseId: String
        public var parentCourseReference: String
        public var createdAt: Date
        public var updatedAt: Date?
        public var climbedDate: Date
        public var type: ClimbedRecordType

        public init(
            id: String,
            registeredUserId: String,
            parentCourseId: String,
            parentCourseReference: String,
            createdAt: Date,
            updatedAt: Date?,
            climbedDate: Date,
            type: Domain.Entity.ClimbRecord.ClimbedRecordType
        ) {
            self.id = id
            self.registeredUserId = registeredUserId
            self.parentCourseId = parentCourseId
            self.parentCourseReference = parentCourseReference
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.climbedDate = climbedDate
            self.type = type
        }
    }
}

public extension Domain.Entity.ClimbRecord {
    enum ClimbedRecordType: String, CaseIterable, Codable {
        case flash, redPoint

        public var name: String {
            switch self {
            case .flash:
                return "Flash"

            case .redPoint:
                return "RedPoint"
            }
        }

        public var fieldName: String {
            switch self {
            case .flash:
                return "flashTotal"

            case .redPoint:
                return "redPointTotal"
            }
        }

        public var isFlash: Bool {
            self == .flash
        }

        public var isRedpoint: Bool {
            self == .redPoint
        }
    }
}
