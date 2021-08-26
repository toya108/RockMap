
import Combine
import Foundation

public extension FS.Request.Rock {
    struct Delete: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let id: String
            let parentPath: String

            public init(id: String, parentPath: String) {
                self.id = id
                self.parentPath = parentPath
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            parameters.parentPath
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
            entry.delete()
        }

    }
}
