
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {

    struct Course: DocumentProtocol, UserRegisterableDocumentProtocol {
        
        public var collection: CollectionProtocol.Type { FS.Collection.Courses.self }

        public var id: String = UUID().uuidString
        public var parentPath: String
        public var createdAt: Date = Date()
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
        public var imageUrls: [URL] = []
    }

}
