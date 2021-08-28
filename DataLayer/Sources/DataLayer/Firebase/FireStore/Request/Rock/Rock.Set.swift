import Combine
import Foundation

public extension FS.Request.Rock {
    struct Set: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let rock: FS.Document.Rock

            public init(rock: FS.Document.Rock) {
                self.rock = rock
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { parameters.rock }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            entry.setData(from: parameters.rock)
        }

    }
}
