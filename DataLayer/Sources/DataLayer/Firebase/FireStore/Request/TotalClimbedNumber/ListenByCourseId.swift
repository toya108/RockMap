import Combine
import Foundation

public extension FS.Request.TotalClimbedNumber {
    struct ListenByCourseId: FirestoreListenableProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.TotalClimbedNumber
        public typealias Response = FS.Document.TotalClimbedNumber
        public struct Parameters: Codable {
            let parentPath: String
            let courseId: String

            public init(parentPath: String, courseId: String) {
                self.parentPath = parentPath
                self.courseId = courseId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.parentPath
            FS.Collection.Courses.name
            self.parameters.courseId
        }

        public var entry: Entry {
            FirestoreManager.db.document(self.path).collection(Collection.name)
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
