
import Foundation

public extension FS.Request {
    struct Upload: StorageRequestProtocol {
        public typealias Collection = FS.Collection.Courses
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let documentId: String
            let imageType: ImageType

            public init(documentId: String, imageType: ImageType) {
                self.documentId = documentId
                self.imageType = imageType
            }
        }

        public var method: StorageMethod { .upload }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
            parameters.documentId
            
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}
