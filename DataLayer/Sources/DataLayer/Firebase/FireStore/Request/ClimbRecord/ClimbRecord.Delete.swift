import Combine
import Foundation
import Utilities

public extension FS.Request.ClimbRecord {
    struct Delete: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var id: String

            public init(id: String) {
                self.id = id
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry { Collection.collection.document(parameters.id) }
        public var path: String { "" }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.delete()
        }
    }
}
