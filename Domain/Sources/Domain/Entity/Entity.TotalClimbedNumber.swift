
import Foundation

extension Domain.Entity {
    public struct TotalClimbedNumber: EntityProtocol {
        var id: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var flash: Int
        var redPoint: Int
    }
}
