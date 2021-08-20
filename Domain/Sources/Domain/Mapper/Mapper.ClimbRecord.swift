
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
                totalNumberReference: other.totalNumberReference.path,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                parentPath: other.parentPath,
                climbedDate: other.climbedDate,
                type: .init(rawValue: other.type) ?? .flash
            )
        }

        public func reverse(to other: Domain.Entity.ClimbRecord) -> FS.Document.ClimbRecord {
            .init(
                id: other.id,
                registeredUserId: other.registeredUserId,
                parentCourseId: other.parentCourseId,
                parentCourseReference: other.parentCourseReference,
                totalNumberReference: other.totalNumberReference,
                createdAt: other.createdAt,
                parentPath: other.parentPath,
                climbedDate: other.climbedDate,
                type: other.type.rawValue
            )
        }

    }

}
