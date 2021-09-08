
import Foundation

public extension Domain.Entity {
    struct TotalClimbedNumber: AnyEntity {
        public var flash: Int
        public var redPoint: Int
        public var total: Int { self.flash + self.redPoint }

        public init(
            flash: Int,
            redPoint: Int
        ) {
            self.flash = flash
            self.redPoint = redPoint
        }
    }
}
