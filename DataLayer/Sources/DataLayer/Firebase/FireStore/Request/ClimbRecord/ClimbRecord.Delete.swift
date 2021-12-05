import Combine
import Foundation
import Utilities

public extension FS.Request.ClimbRecord {
    struct Delete: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var parentPath: String
            public var id: String

            public init(parentPath: String, id: String) {
                self.parentPath = parentPath
                self.id = id
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.parentPath
            Collection.name
            self.parameters.id
        }

        public var entry: Entry { FirestoreManager.db.document(self.path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.delete()
        }
    }
}
