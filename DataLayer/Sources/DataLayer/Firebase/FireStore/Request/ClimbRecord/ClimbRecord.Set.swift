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
            public var parentPath: String
            public var climbedDate: Date
            public var type: String

            public init(
                id: String,
                registeredUserId: String,
                parentCourseId: String,
                parentCourseReference: String,
                createdAt: Date,
                updatedAt: Date? = nil,
                parentPath: String,
                climbedDate: Date,
                type: String
            ) {
                self.id = id
                self.registeredUserId = registeredUserId
                self.parentCourseId = parentCourseId
                self.parentCourseReference = parentCourseReference
                self.createdAt = createdAt
                self.updatedAt = updatedAt
                self.parentPath = parentPath
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
            FirestoreManager.db
                .document(parameters.parentCourseReference)
                .collection(FS.Collection.TotalClimbedNumber.name)
                .getDocuments(FS.Document.TotalClimbedNumber.self)
                .tryMap { documents -> FS.Document.TotalClimbedNumber in
                    guard let document = documents.first else {
                        throw FirestoreError.nilResultError
                    }
                    return document
                }
                .flatMap { totalNumber -> AnyPublisher<EmptyResponse, Error> in

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
                        parentPath: parameters.parentPath,
                        climbedDate: parameters.climbedDate,
                        type: parameters.type
                    )

                    return entry.setData(from: climbRecord)
                }
                .eraseToAnyPublisher()
        }
    }
}
