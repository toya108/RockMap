
import Foundation

extension FS.Request {
    struct GetUser: FirestoreRequestProtocol {
        typealias Collection = FS.Collection.Users
        typealias Response = FS.Document.User
        public struct Parameters: Codable {
            let id: String

            public init(id: String) {
                self.id = id
            }
        }

        var method: FirestoreMethod { .get }
        var parameters: Parameters
        var testDataPath: URL?
        var path: String {
            Collection.name
            parameters.id
        }

        init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}

