
import FirebaseFirestoreSwift
import Foundation

public extension FS.Document {
    struct User: DocumentProtocol {
        public var collection: CollectionProtocol.Type { FS.Collection.Users.self }

        public var id: String
        public var createdAt: Date
        @ExplicitNull public var updatedAt: Date?
        public var parentPath: String = ""
        public var name: String
        @ExplicitNull public var photoURL: URL?
        public var socialLinks: [SocialLink]
        @ExplicitNull public var introduction: String?
        @ExplicitNull public var headerUrl: URL?
        public var deleted: Bool = false

        public struct SocialLink: Hashable, Codable {
            public let linkType: String
            public var link: String

            public init(
                linkType: String,
                link: String
            ) {
                self.linkType = linkType
                self.link = link
            }
        }

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date?,
            name: String,
            photoURL: URL?,
            socialLinks: [FS.Document.User.SocialLink],
            introduction: String?,
            headerUrl: URL?,
            deleted: Bool = false
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.photoURL = photoURL
            self.socialLinks = socialLinks
            self.introduction = introduction
            self.headerUrl = headerUrl
            self.deleted = deleted
        }
    }
}
