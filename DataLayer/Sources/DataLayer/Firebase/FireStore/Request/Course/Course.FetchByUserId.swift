
import Combine
import Foundation

public extension FS.Request.Course {
    struct FetchByUserId: FirestoreRequestProtocol {
        public typealias Entry = FSQuery

        public typealias Collection = FS.Collection.Courses
        public typealias Response = [FS.Document.Course]
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

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<[FS.Document.Course], Error> {
            self.entry.getDocuments(Response.Element.self)
        }
    }
}
