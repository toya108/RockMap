import FirebaseFirestoreSwift
import Foundation

public extension FS.Document {
    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {

        public var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        public var id: String
        public var registeredUserId: String
        public var parentCourseId: String
        public var parentCourseReference: FSDocument
        // This property is used by cloudFunction
        public var totalNumberReference: FSDocument
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String = ""
        public var climbedDate: Date
        public var type: String

        public init(
            id: String,
            registeredUserId: String,
            parentCourseId: String,
            parentCourseReference: FSDocument,
            totalNumberReference: FSDocument,
            createdAt: Date,
            updatedAt: Date?,
            climbedDate: Date,
            type: String
        ) {
            self.id = id
            self.registeredUserId = registeredUserId
            self.parentCourseId = parentCourseId
            self.parentCourseReference = parentCourseReference
            self.totalNumberReference = totalNumberReference
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.climbedDate = climbedDate
            self.type = type
        }
    }
}
