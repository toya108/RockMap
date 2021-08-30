
import Combine
import Foundation

public extension FS.Request.Course {
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

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { parameters.course }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            entry.updateData(parameters.course.dictionary)
        }

    }
}
