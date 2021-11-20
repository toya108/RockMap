import Combine
import Foundation

public extension FireStorage.Request {
    struct Set: StorageRequestProtocol {
        public typealias Response = EmptyResponse

        public struct Parameters {
            let path: String
            let data: Data

            public init(
                path: String,
                data: Data
            ) {
                self.path = path
                self.data = data
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
            try await StorageAssets.storage.reference(withPath: self.path).putData(parameters.data)
        }
    }
}
