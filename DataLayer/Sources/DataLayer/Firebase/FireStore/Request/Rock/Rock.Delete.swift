import Combine
import Foundation

public extension FS.Request.Rock {
    struct Delete: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let id: String
            let parentPath: String

            public init(id: String, parentPath: String) {
                self.id = id
                self.parentPath = parentPath
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

        public func request() async throws -> EmptyResponse {
            try await self.entry.delete()
        }
    }
}
