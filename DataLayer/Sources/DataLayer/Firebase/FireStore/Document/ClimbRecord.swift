import FirebaseFirestoreSwift
import Foundation

public extension FS.Document {
    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {

        public var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        public var id: String
        public var registeredUserId: String
        public var parentCourseId: String
        public var parentCourseReference: FSDocument
        @ExplicitNull
        public var totalNumberReference: FSDocument?
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var climbedDate: Date
        public var type: String

        public init(
            id: String,
            registeredUserId: String,
            parentCourseId: String,
            parentCourseReference: FSDocument,
            createdAt: Date,
            updatedAt: Date?,
            parentPath: String,
            climbedDate: Date,
            type: String
        ) {
            self.id = id
            self.registeredUserId = registeredUserId
            self.parentCourseId = parentCourseId
            self.parentCourseReference = parentCourseReference
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.climbedDate = climbedDate
            self.type = type
        }
    }
}
