import Foundation

public extension FS.Request.Course {
    struct FetchByRockId: FirestoreRequestProtocol {

        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let rockId: String

            public init(rockId: String) {
                self.rockId = rockId
            }
        }

        public var method: FirestoreMethod { .get }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.group.whereField("parentRockId", in: [parameters.rockId])
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}
