import Combine
import Foundation

public extension FS.Request.Rock {
    struct FetchAll: FirestoreRequestProtocol {
        public typealias Entry = FSQuery
        public typealias Parameters = EmptyParameters

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = [FS.Document.Rock]

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocuments(Response.Element.self)
        }
    }
}
