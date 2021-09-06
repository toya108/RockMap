import Combine
import Foundation

public extension FireStorage.Request.Normal {
    struct Fetch: StorageRequestProtocol {

        public typealias Directory = FireStorage.ImageDirectory.Normal

        public typealias Response = [FireStorage.Image]

        public struct Parameters {
            let documentId: String
            let collectionType: CollectionProtocol.Type

            public init(documentId: String, collectionType: CollectionProtocol.Type) {
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
        ) -> AnyPublisher<[FireStorage.Image], Error> {
            StorageAssets.storage.reference(withPath: path)
                .getPrefixes()
                .flatMap {
                    $0.getReferences()
                }
                .flatMap {
                    $0.publisher.flatMap { $0.getImage() } .collect()
                }
                .eraseToAnyPublisher()
        }

    }
}
