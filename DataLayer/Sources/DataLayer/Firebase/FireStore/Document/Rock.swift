
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

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
        public var desc: String
        public var registeredUserId: String
        @ExplicitNull
        public var headerUrl: URL?
        public var imageUrls: [URL]

        public init(
            id: String,
            createdAt: Date,
            parentPath: String,
            name: String,
            address: String,
            prefecture: String,
            location: GeoPoint,
            seasons: Set<String>,
            lithology: String,
            desc: String,
            registeredUserId: String,
            imageUrls: [URL] = []
        ) {
            self.id = id
            self.createdAt = createdAt
            self.parentPath = parentPath
            self.name = name
            self.address = address
            self.prefecture = prefecture
            self.location = location
            self.seasons = seasons
            self.lithology = lithology
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.imageUrls = imageUrls
        }

    }
}
