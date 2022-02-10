import Combine
import Foundation

public extension FS.Request.ClimbRecord {
    struct FetchByCourseId: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = [FS.Document.ClimbRecord]
        public struct Parameters: Codable {
            let courseId: String

            public init(courseId: String) {
                self.courseId = courseId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection
                .whereField("parentCourseId", isEqualTo: self.parameters.courseId)
                .order(by: "climbedDate")
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocuments(Response.Element.self)
        }
    }
}
