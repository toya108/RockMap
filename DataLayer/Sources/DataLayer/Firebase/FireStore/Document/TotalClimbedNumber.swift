
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {

    struct TotalClimbedNumber: DocumentProtocol {

        public var collection: CollectionProtocol.Type { FS.Collection.TotalClimbedNumber.self }

        public var id: String
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var flash: Int
        public var redPoint: Int

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date?,
            parentPath: String,
            flash: Int,
            redPoint: Int
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.flash = flash
            self.redPoint = redPoint
        }
    }
    
}
