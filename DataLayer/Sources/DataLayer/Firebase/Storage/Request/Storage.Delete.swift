import Combine
import Foundation

public extension FireStorage.Request {
    struct Delete: StorageRequestProtocol {
        public typealias Response = EmptyResponse

        public struct Parameters {
            let path: String

            public init(path: String) {
                self.path = path
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.path
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await StorageAssets.storage.reference(withPath: self.path).delete()
        }
    }
}
