
import Foundation
import FirebaseFirestoreSwift

extension FS.Document {

    struct TotalClimbedNumber: DocumentProtocol {

        var collection: CollectionProtocol.Type { FS.Collection.TotalClimbedNumber.self }

        var id: String
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var flash: Int
        var redPoint: Int
    }
    
}
