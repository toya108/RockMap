import Combine
import Foundation

public extension FS.Request.ClimbRecord {
    struct Set: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.ClimbRecord
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            public var id: String
            public var registeredUserId: String
            public var parentCourseId: String
            public var parentCourseReference: String
            public var createdAt: Date
            public var updatedAt: Date?
            public var climbedDate: Date
            public var type: String

            public init(
                id: String,
                registeredUserId: String,
                parentCourseId: String,
                parentCourseReference: String,
                createdAt: Date,
                updatedAt: Date? = nil,
                climbedDate: Date,
                type: String
            ) {
                self.id = id
                self.registeredUserId = registeredUserId
                self.parentCourseId = parentCourseId
                self.parentCourseReference = parentCourseReference
                self.createdAt = createdAt
                self.updatedAt = updatedAt
                self.climbedDate = climbedDate
                self.type = type
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String { "" }

        public var entry: Entry { Collection.collection.document(self.parameters.id) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            let totalNumber = try await FirestoreManager.db
                .document(parameters.parentCourseReference)
                .collection(FS.Collection.TotalClimbedNumber.name)
                .getDocument(FS.Document.TotalClimbedNumber.self)

            let climbRecord = FS.Document.ClimbRecord(
                id: parameters.id,
                registeredUserId: parameters.registeredUserId,
                parentCourseId: parameters.parentCourseId,
                parentCourseReference: FirestoreManager.db.document(
                    parameters.parentCourseReference
                ),
                totalNumberReference: totalNumber.reference,
                createdAt: parameters.createdAt,
                updatedAt: parameters.updatedAt,
                climbedDate: parameters.climbedDate,
                type: parameters.type
            )

            return try await entry.setData(from: climbRecord)
        }
    }
}
