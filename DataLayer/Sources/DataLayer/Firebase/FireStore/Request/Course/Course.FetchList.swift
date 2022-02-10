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
            let grade: String

            public init(limit: Int = 20, startAt: Date, grade: String) {
                self.limit = limit
                self.startAt = startAt
                self.grade = grade
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            var query = Collection.collection.limit(to: parameters.limit)

            if !parameters.grade.isEmpty {
                query = query.whereField("grade", isEqualTo: parameters.grade)
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
