
import DataLayer
import Foundation

public extension Domain.Mapper {

    struct TotalClimbedNumber: MapperProtocol {

        public typealias TotalClimbedNumber = Domain.Entity.TotalClimbedNumber

        public init() {}

        public func map(from other: FS.Document.TotalClimbedNumber) -> TotalClimbedNumber {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                parentPath: other.parentPath,
                flash: other.flash,
                redPoint: other.redPoint
            )
        }

        public func reverse(to other: Domain.Entity.TotalClimbedNumber) -> FS.Document.TotalClimbedNumber {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                parentPath: other.parentPath,
                flash: other.flash,
                redPoint: other.redPoint
            )
        }

    }

}
