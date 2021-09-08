
import Combine
import Foundation
import Utilities

public extension FS.Request.ClimbRecord {
    struct Update: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var parentPath: String
            public var id: String
            public var climbedDate: Date?
            public var type: String?

            public init(parentPath: String, id: String, climbedDate: Date?, type: String?) {
                self.parentPath = parentPath
                self.id = id
                self.climbedDate = climbedDate
                self.type = type
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            self.parameters.parentPath
            Collection.name
            self.parameters.id
        }

        public var entry: Entry { FirestoreManager.db.document(self.path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {
            @ListBuilder<[AnyHashable: Any]>
            var updateFields: [[AnyHashable: Any]] {
                if let climbedDate = parameters.climbedDate {
                    ["climbedDate": climbedDate]
                }

                if let type = parameters.type {
                    ["type": type]
                }
            }

            let fields = updateFields.flatMap { $0 }.reduce([AnyHashable: Any]()) {
                var result = $0
                result[$1.key] = $1.value
                return result
            }

            return self.entry.updateData(fields)
        }
    }
}
