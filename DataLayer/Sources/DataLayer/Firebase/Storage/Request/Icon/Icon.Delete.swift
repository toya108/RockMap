
import Combine
import Foundation

public extension FireStorage.Request.Icon {
    struct Delete: StorageRequestProtocol {

        public typealias Directory = FireStorage.ImageDirectory.Icon

        public typealias Response = EmptyResponse

        public struct Parameters {
            let documentId: String
            let collectionType: CollectionProtocol.Type

            public init(
                documentId: String,
                collectionType: CollectionProtocol.Type
            ) {
                self.documentId = documentId
                self.collectionType = collectionType
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
                .flatMap { $0.delete() }
                .eraseToAnyPublisher()
        }

    }
}
