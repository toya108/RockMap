import Combine
import Foundation

public extension FireStorage.Request {
    struct Delete: StorageRequestProtocol {

        public enum StorageEntry {
            case file(path: String)
            case directory(path: String)
        }

        public typealias Response = EmptyResponse

        public struct Parameters {
            let entry: StorageEntry

            public init(entry: StorageEntry) {
                self.entry = entry
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { "" }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            switch parameters.entry {
                case let .file(path):
                    return try await StorageAssets.storage.reference(withPath: path).deleteStorage()

                case let .directory(path):
                    return try await StorageAssets.storage.reference(withPath: path).deleteDirectory()
            }

        }
    }
}
