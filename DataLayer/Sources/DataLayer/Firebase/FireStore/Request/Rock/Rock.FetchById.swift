import Combine
import Foundation

public extension FS.Request.Rock {
    struct FetchById: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = FS.Document.Rock
        public struct Parameters: Codable {
            let id: String

            public init(id: String) {
                self.id = id
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection.whereField("id", isEqualTo: self.parameters.id)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocument(Response.self)
        }
    }
}
