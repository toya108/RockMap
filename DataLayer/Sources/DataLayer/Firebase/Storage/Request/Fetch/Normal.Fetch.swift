import Combine
import Foundation

public extension FireStorage.Request.Fetch {
    struct Normal: StorageRequestProtocol {
        public typealias Response = [FireStorage.Image]

        public struct Parameters {
            let documentId: String
            let collectionType: CollectionProtocol.Type
            let directory: ImageDirectory

            public init(
                documentId: String,
                collectionType: CollectionProtocol.Type,
                directory: ImageDirectory
            ) {
                self.documentId = documentId
                self.collectionType = collectionType
                self.directory = directory
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.collectionType.name
            self.parameters.documentId
            self.parameters.directory.rawValue
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<[FireStorage.Image], Error> {
            StorageAssets.storage.reference(withPath: self.path)
                .getPrefixes()
                .flatMap {
                    $0.getReferences()
                }
                .flatMap {
                    $0.publisher.flatMap { $0.getImage() }.collect()
                }
                .eraseToAnyPublisher()
        }
    }
}
