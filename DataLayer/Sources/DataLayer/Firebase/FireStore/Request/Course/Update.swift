import Foundation

public extension FS.Request {
    struct Update: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Courses
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let course: FS.Document.Course

            public init(course: FS.Document.Course) {
                self.course = course
            }
        }

        public var method: FirestoreMethod { .update }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { parameters.course }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}
