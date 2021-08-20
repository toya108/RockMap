
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {

    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {
        
        public var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        public var id: String
        public var registeredUserId: String
        public var parentCourseId: String
        public var parentCourseReference: FSDocument
        public var totalNumberReference: FSDocument
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var climbedDate: Date
        public var type: String
//
//        public init(
//            id: String,
//            registeredUserId: String,
//            parentCourseId: String,
//            parentCourseReference: String,
//            createdAt: Date,
//            parentPath: String,
//            climbedDate: Date,
//            type: String
//        ) {
//            self.id = id
//            self.registeredUserId = registeredUserId
//            self.parentCourseId = parentCourseId
//            self.parentCourseReference = FirestoreManager.db.document(parentCourseReference)
//            self.totalNumberReference = FirestoreManager.db.document(totalNumberReference)
//            self.createdAt = createdAt
//            self.parentPath = parentPath
//            self.climbedDate = climbedDate
//            self.type = type
//        }
    }

}
