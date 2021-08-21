
import Combine
import Foundation
import Utilities

public extension FS.Request.User {
    struct Update: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var id: String
            public var name: String?
            public var introduction: String?
            public var socialLinks: [FS.Document.User.SocialLink]?
            public init(
                id: String,
                name: String?,
                introduction: String?,
                socialLinks: [FS.Document.User.SocialLink]?
            ) {
                self.id = id
                self.name = name
                self.introduction = introduction
                self.socialLinks = socialLinks
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
            parameters.id
        }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {

            @ListBuilder<[AnyHashable: Any]>
            var updateFields: [[AnyHashable: Any]] {
                if let name = parameters.name {
                    ["name": name]
                }

                if let introduction = parameters.introduction {
                    ["introduction": introduction]
                }

                if let socialLinks = parameters.socialLinks {
                    ["socialLinks": socialLinks]
                }

            }

            let fields = updateFields.flatMap { $0 }.reduce([AnyHashable: Any]()) {
                var result = $0
                result[$1.key] = $1.value
                return result
            }

            return entry.updateData(fields)
        }

    }
}
