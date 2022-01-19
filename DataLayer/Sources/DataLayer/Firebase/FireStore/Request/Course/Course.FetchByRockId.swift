import Combine
import Foundation

public extension FS.Request.Course {
    struct FetchByRockId: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let rockId: String

            public init(rockId: String) {
                self.rockId = rockId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            FS.Collection.Rocks.collection.whereField(
                "parentRockId",
                isEqualTo: self.parameters.rockId
            )
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocuments(Response.Element.self)
        }
    }
}
