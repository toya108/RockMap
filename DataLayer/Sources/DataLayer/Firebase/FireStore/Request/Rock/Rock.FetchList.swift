import Foundation
import Utilities

public extension FS.Request.Rock {
    struct FetchList: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = [FS.Document.Rock]
        public struct Parameters: Codable {
            let limit: Int
            let startAt: Date
            let area: String

            public init(limit: Int = 20, startAt: Date, area: String) {
                self.limit = limit
                self.startAt = startAt
                self.area = area
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            var query = Collection.collection.limit(to: parameters.limit)

            if !parameters.area.isEmpty {
                query = query.whereField("area", isEqualTo: parameters.area)
            }

            query = query
                .order(by: "createdAt", descending: true)
                .start(at: [parameters.startAt])

            return query
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await entry.getDocuments(Response.Element.self)
        }
    }
}
