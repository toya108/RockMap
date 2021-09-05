
import Combine
import Foundation

public extension FireStorage.Request.Header {
    struct Delete: StorageRequestProtocol {

        public typealias Directory = FireStorage.ImageDirectory.Header

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
            parameters.path
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            StorageAssets.storage.reference(withPath: path)
                .delete()
                .eraseToAnyPublisher()
        }

    }
}
