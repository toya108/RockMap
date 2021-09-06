
import Combine
import Foundation

public extension FireStorage.Request.Image {
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
                .putData(parameters.data)
                .eraseToAnyPublisher()
        }

    }
}
