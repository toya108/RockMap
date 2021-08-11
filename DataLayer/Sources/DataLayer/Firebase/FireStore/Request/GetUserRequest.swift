
import Foundation

public extension FS.Request {
    struct GetUser: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = FS.Document.User
        public struct Parameters: Codable {
            let id: String

            public init(id: String) {
                self.id = id
            }
        }

        public var method: FirestoreMethod { .get }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
            parameters.id
        }
        public var entry: Entry {
            FirestoreManager.db.document(path)
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}

