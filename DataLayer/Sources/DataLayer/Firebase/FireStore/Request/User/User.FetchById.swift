import Combine
import Foundation

public extension FS.Request.User {
    struct FetchById: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = FS.Document.User
        public struct Parameters: Codable {
            let id: String

            public init(id: String) {
                self.id = id
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
            self.parameters.id
        }

        public var entry: Entry {
            FirestoreManager.db.document(self.path)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocument()
        }
    }
}
