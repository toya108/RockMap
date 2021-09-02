
import Combine
import Foundation

public extension FireStorage.Request.Header {
    struct Set: StorageRequestProtocol {

        public typealias Directory = FireStorage.ImageDirectory.Header

        public typealias Response = EmptyResponse

        public struct Parameters {
            let documentId: String
            let collectionType: CollectionProtocol.Type
            let data: Data

            public init(
                documentId: String,
                collectionType: CollectionProtocol.Type,
                data: Data
            ) {
                self.documentId = documentId
                self.collectionType = collectionType
                self.data = data
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            parameters.collectionType.name
            parameters.documentId
            Directory.name
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            StorageAssets.storage.reference(withPath: path)
                .getReference()
                .flatMap { $0.putData(parameters.data) }
                .eraseToAnyPublisher()
        }

    }
}
