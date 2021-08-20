
import UIKit
import FirebaseFirestoreSwift

public extension Domain.Entity {

    struct ClimbRecord: EntityProtocol {
        var id: String
        var registeredUserId: String
        var parentCourseId: String
        var parentCourseReference: String
        var totalNumberReference: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType
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
