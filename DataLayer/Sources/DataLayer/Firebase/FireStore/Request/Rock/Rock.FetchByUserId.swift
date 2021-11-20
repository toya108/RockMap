import Combine
import Foundation

public extension FS.Request.Rock {
    struct FetchByUserId: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = [FS.Document.Rock]
        public struct Parameters: Codable {
            let userId: String

            public init(userId: String) {
                self.userId = userId
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            Collection.group.whereField("registeredUserId", in: [self.parameters.userId])
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            try await self.entry.getDocuments(Response.Element.self)
        }
    }
}
