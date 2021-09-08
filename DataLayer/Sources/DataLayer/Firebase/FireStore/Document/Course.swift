
import FirebaseFirestoreSwift
import Foundation

public extension FS.Document {
    struct Course: DocumentProtocol, UserRegisterableDocumentProtocol {
        public var collection: CollectionProtocol.Type { FS.Collection.Courses.self }

        public var id: String
        public var parentPath: String
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var name: String
        public var desc: String
        public var grade: String
        public var shape: Set<String>
        public var parentRockName: String
        public var parentRockId: String
        public var registeredUserId: String
        @ExplicitNull
        public var headerUrl: URL?
        public var imageUrls: [URL]

        public init(
            id: String,
            parentPath: String,
            createdAt: Date,
            updatedAt: Date?,
            name: String,
            desc: String,
            grade: String,
            shape: Set<String>,
            parentRockName: String,
            parentRockId: String,
            registeredUserId: String,
            headerUrl: URL?,
            imageUrls: [URL]
        ) {
            self.id = id
            self.parentPath = parentPath
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.desc = desc
            self.grade = grade
            self.shape = shape
            self.parentRockName = parentRockName
            self.parentRockId = parentRockId
            self.registeredUserId = registeredUserId
            self.headerUrl = headerUrl
            self.imageUrls = imageUrls
        }
    }
}
