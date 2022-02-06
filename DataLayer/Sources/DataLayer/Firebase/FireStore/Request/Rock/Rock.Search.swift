import Foundation
import Utilities

public extension FS.Request.Rock {
    struct Search: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Rocks
        public typealias Response = [FS.Document.Rock]
        public struct Parameters: Codable {
            let text: String
            let lithology: String
            let seasons: [String]
            let prefecture: String

            public init(
                text: String,
                lithology: String,
                seasons: [String],
                prefecture: String
            ) {
                self.text = text
                self.lithology = lithology
                self.seasons = seasons
                self.prefecture = prefecture
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            let searchTextMap = NGramGenerator.makeNGram(input: parameters.text, n: 2)
            var query = Collection.collection.limit(to: 20)

            if !parameters.lithology.isEmpty {
                query = query.whereField("lithology", isEqualTo: parameters.lithology)
            }

            if !parameters.seasons.isEmpty {
                query = query.whereField("seasons", in: parameters.seasons)
            }

            if !parameters.prefecture.isEmpty {
                query = query.whereField("prefecture", isEqualTo: parameters.prefecture)
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
