import Foundation
import Utilities

public extension FS.Request.Course {
    struct Search: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
        public struct Parameters: Codable {
            let text: String
            let grade: String

            public init(text: String, grade: String) {
                self.text = text
                self.grade = grade
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var entry: Entry {
            let searchTextMap = NGramGenerator.makeNGram(input: parameters.text, n: 2)
            var query = Collection.collection.limit(to: 20)

            if !parameters.grade.isEmpty {
                query = query.whereField("grade", isEqualTo: parameters.grade)
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
