import Combine
import Foundation

public extension FS.Request.Course {
    struct Set: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Courses
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let course: FS.Document.Course

            public init(course: FS.Document.Course) {
                self.course = course
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { self.parameters.course }
        public var entry: Entry { FirestoreManager.db.document(self.path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            FirestoreManager.db.document(self.path).setData(from: parameters.course)
        }
    }
}
