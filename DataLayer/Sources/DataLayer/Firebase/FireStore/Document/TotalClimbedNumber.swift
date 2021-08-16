
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {

    struct TotalClimbedNumber: DocumentProtocol {

        public var collection: CollectionProtocol.Type { FS.Collection.TotalClimbedNumber.self }

        public var id: String
        public var createdAt: Date = Date()
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var flash: Int
        public var redPoint: Int
    }
    
}
