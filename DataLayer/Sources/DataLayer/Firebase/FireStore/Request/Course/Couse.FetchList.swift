import Foundation
import Utilities

public extension FS.Request.Course {
    struct FetchList: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let limit: Int
            let page: Int

            public init(limit: Int = 20, page: Int) {
                self.limit = limit
                self.page = page
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection
                .limit(to: parameters.limit)
                .start(at: [parameters.limit * parameters.page])
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await entry.getDocuments(Response.Element.self)
        }
    }
}
