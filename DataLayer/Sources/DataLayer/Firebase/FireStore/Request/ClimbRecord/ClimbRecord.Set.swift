import Foundation

public extension FS.Request.ClimbRecord {
    struct Set: FirestoreRequestProtocol {

        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let climbRecord: FS.Document.ClimbRecord

            public init(climbRecord: FS.Document.ClimbRecord) {
                self.climbRecord = climbRecord
            }
        }

        public var method: FirestoreMethod { .set }
        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            parameters.climbRecord
        }
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

    }
}
