
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {

    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {
        
        public var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        public var id: String = UUID().uuidString
        public var registeredUserId: String
        public var parentCourseId: String
        public var parentCourseReference: FSDocument
        public var totalNumberReference: FSDocument
        public var createdAt: Date = Date()
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var climbedDate: Date
        public var type: String
    }

}
