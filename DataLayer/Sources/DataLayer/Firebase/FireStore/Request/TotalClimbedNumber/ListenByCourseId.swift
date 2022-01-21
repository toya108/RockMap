import Combine
import Foundation

public extension FS.Request.TotalClimbedNumber {
    struct ListenByCourseId: FirestoreListenableProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.TotalClimbedNumber
        public typealias Response = FS.Document.TotalClimbedNumber
        public struct Parameters: Codable {
            let courseId: String

            public init(courseId: String) {
                self.courseId = courseId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { "" }

        public var entry: Entry {
            FS.Collection.Courses
                .collection
                .document(parameters.courseId)
                .collection(Collection.name)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() -> AnyPublisher<Response, Error> {
            return self.entry.listen(to: Response.self)
                .compactMap { $0.first }
                .eraseToAnyPublisher()
        }
    }
}
