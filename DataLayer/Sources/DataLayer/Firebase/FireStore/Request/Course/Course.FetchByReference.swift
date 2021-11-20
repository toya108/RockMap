import Combine
import Foundation

public extension FS.Request.Course {
    struct FetchByReference: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Courses
        public typealias Response = FS.Document.Course
        public struct Parameters: Codable {
            let reference: String

            public init(reference: String) {
                self.reference = reference
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { "" }
        public var entry: Entry {
            FirestoreManager.db.document(self.parameters.reference)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocument()
        }
    }
}
