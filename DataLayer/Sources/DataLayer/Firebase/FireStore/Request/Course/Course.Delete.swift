import Combine
import Foundation

public extension FS.Request.Course {
    struct Delete: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Courses
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let id: String

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
