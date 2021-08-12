
import Foundation
import FirebaseFirestoreSwift

extension FS.Document {

    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {
        
        var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        var id: String = UUID().uuidString
        var registeredUserId: String
        var parentCourseId: String
        var parentCourseReference: FSDocument
        var totalNumberReference: FSDocument
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: String
    }

}
