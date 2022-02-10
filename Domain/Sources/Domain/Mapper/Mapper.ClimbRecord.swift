import DataLayer
import Foundation

public extension Domain.Mapper {
    struct ClimbRecord: MapperProtocol {
        public typealias ClimbRecord = Domain.Entity.ClimbRecord

        public init() {}

        public func map(from other: FS.Document.ClimbRecord) -> ClimbRecord {
            .init(
                id: other.id,
                registeredUserId: other.registeredUserId,
                parentCourseId: other.parentCourseId,
                parentCourseReference: other.parentCourseReference.path,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                climbedDate: other.climbedDate,
                type: .init(rawValue: other.type) ?? .flash
            )
        }
    }
}
