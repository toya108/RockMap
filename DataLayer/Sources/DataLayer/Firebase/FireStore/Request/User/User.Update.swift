import Combine
import FirebaseFirestore
import Foundation
import Utilities

public extension FS.Request.User {
    struct Update: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var user: FS.Document.User

            public init(user: FS.Document.User) {
                self.user = user
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.user
        }

        public var entry: Entry { FirestoreManager.db.document(self.path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.setData(from: parameters.user)
        }
    }
}
