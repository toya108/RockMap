import Combine
import Foundation

public extension FS.Request.ClimbRecord {
    struct FetchByUserId: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = [FS.Document.ClimbRecord]
        public struct Parameters: Codable {
            let userId: String

            public init(userId: String) {
                self.userId = userId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.collection.whereField(
                "registeredUserId",
                isEqualTo: self.parameters.userId
            )
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocuments(Response.Element.self)
        }
    }
}
