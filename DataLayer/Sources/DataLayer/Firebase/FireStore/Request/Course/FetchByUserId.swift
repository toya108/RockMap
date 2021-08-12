import Foundation

public extension FS.Request {
    struct FetchByUserId: FirestoreRequestProtocol {

        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let userId: String

            public init(userId: String) {
                self.userId = userId
            }
        }

        public var method: FirestoreMethod { .get }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.group.whereField("registeredUserId", in: [parameters.userId])
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}
