import Foundation
import Utilities

public extension FS.Request.Course {
    struct FetchList: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let limit: Int
            let startAt: Date

            public init(limit: Int = 20, startAt: Date) {
                self.limit = limit
                self.startAt = startAt
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection
                .limit(to: parameters.limit)
                .order(by: "createdAt", descending: true)
                .start(at: [parameters.startAt])
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await entry.getDocuments(Response.Element.self)
        }
    }
}
