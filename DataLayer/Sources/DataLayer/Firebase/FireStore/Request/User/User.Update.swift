
import Combine
import Foundation
import Utilities
import FirebaseFirestore

public extension FS.Request.User {
    struct Update: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var user: FS.Document.User

            public init(user: FS.Document.User) {
                self.user = user
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            parameters.user
        }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            return entry.setData(from: parameters.user)
        }

    }
}
