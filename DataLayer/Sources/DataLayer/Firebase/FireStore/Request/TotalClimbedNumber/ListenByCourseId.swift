
import Foundation

public extension FS.Request.TotalClimbedNumber {
    struct ListenByCourseId: FSListenable {

        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.TotalClimbedNumber
        public typealias Response = [FS.Document.TotalClimbedNumber]
        public struct Parameters: Codable {
            let parentPath: String
            let courseId: String

            public init(parentPath: String, courseId: String) {
                self.parentPath = parentPath
                self.courseId = courseId
            }
        }

        public var method: FirestoreMethod { .listen }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            parameters.parentPath
            FS.Collection.Courses.name
            parameters.courseId
        }
        public var entry: Entry {
            FirestoreManager.db.document(path).collection(Collection.name)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}

