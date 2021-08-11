
import Foundation
import FirebaseFirestoreSwift

public extension FS.Document {
    
    struct User: DocumentProtocol {
        
        public var collection: CollectionProtocol.Type { FS.Collection.Users.self }
        public var id: String
        public var createdAt: Date = Date()
        @ExplicitNull public var updatedAt: Date?
        public var parentPath: String = ""
        public var name: String
        @ExplicitNull public var photoURL: URL?
        public var socialLinks: [SocialLink] = []
        @ExplicitNull public var introduction: String?
        @ExplicitNull public var headerUrl: URL?
        public var deleted: Bool = false
        
        public struct SocialLink: Hashable, Codable {
            public let linkType: String
            public var link: String
        }
    }
}

