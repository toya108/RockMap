import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

public extension FS.Document {
    struct Rock: DocumentProtocol, UserRegisterableDocumentProtocol {
        public var collection: CollectionProtocol.Type { FS.Collection.Rocks.self }

        public var id: String
        public var createdAt: Date
        @ExplicitNull
        public var updatedAt: Date?
        public var parentPath: String
        public var name: String
        public var address: String
        public var prefecture: String
        public var location: GeoPoint
        public var seasons: Set<String>
        public var lithology: String
        public var erea: String?
        public var desc: String
        public var registeredUserId: String
        @ExplicitNull
        public var headerUrl: URL?
        public var imageUrls: [URL]
        public var tokenMap: [String: Bool]?

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date?,
            parentPath: String,
            name: String,
            address: String,
            prefecture: String,
            location: GeoPoint,
            seasons: Set<String>,
            lithology: String,
            erea: String?,
            desc: String,
            registeredUserId: String,
            headerUrl: URL?,
            imageUrls: [URL],
            tokenMap: [String: Bool]?
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.name = name
            self.address = address
            self.prefecture = prefecture
            self.location = location
            self.seasons = seasons
            self.lithology = lithology
            self.erea = erea
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.headerUrl = headerUrl
            self.imageUrls = imageUrls
            self.tokenMap = tokenMap
        }
    }
}
