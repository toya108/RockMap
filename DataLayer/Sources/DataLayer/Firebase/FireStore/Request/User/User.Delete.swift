
import Combine
import Foundation
import Utilities

public extension FS.Request.User {
    struct Delete: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var id: String

            public init(id: String) {
                self.id = id
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
            parameters.id
        }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            return entry.updateData(["deleted": true])
        }

    }
}
