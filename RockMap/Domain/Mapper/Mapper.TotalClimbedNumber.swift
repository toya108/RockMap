import DataLayer
import Foundation

public extension Domain.Mapper {
    struct TotalClimbedNumber: MapperProtocol {
        public typealias TotalClimbedNumber = Domain.Entity.TotalClimbedNumber

        public init() {}

        public func map(from other: FS.Document.TotalClimbedNumber) -> TotalClimbedNumber {
            .init(
                flash: other.flash,
                redPoint: other.redPoint
            )
        }
    }
}
