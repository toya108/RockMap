import Foundation
import Utilities

public extension FS.Request.Rock {
    struct Search: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = [FS.Document.Rock]
        public struct Parameters: Codable {
            let text: String
            let area: String

            public init(
                text: String,
                area: String
            ) {
                self.text = text
                self.area = area
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            let searchTextMap = NGramGenerator.makeNGram(input: parameters.text, n: 2)
            var query = Collection.collection.limit(to: 20)

            if !parameters.area.isEmpty {
                query = query.whereField("area", isEqualTo: parameters.area)
            }

            searchTextMap.forEach { token in
                query = query.whereField("tokenMap.\(token)", isEqualTo: true)
            }

            return query
        }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            NGramGenerator.makeNGram(input: parameters.text, n: 2).isEmpty
                ? []
                : try await entry.getDocuments(Response.Element.self)
        }
    }
}
