import Combine
import Foundation

public extension FS.Request.User {
    struct Set: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let id: String
            let createdAt: Date
            let displayName: String?
            let photoURL: URL?

            public init(
                id: String,
                createdAt: Date,
                displayName: String?,
                photoURL: URL?
            ) {
                self.id = id
                self.createdAt = createdAt
                self.displayName = displayName
                self.photoURL = photoURL
            }
        }

        public var parameters: Parameters
        public var testDataPath: URL?
        public var path: String {
            Collection.name
        }

        public var entry: Entry { FirestoreManager.db.document(self.path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func request() async throws -> Response {
            let userDocument = FS.Document.User(
                id: parameters.id,
                createdAt: parameters.createdAt,
                updatedAt: nil,
                name: parameters.displayName ?? "-",
                photoURL: parameters.photoURL,
                socialLinks: [],
                introduction: nil,
                headerUrl: nil
            )

            let exists = try await userDocument.reference.exists()

            return try await setUserDocument(exists: exists, document: userDocument)
        }

        private func setUserDocument(
            exists: Bool,
            document: FS.Document.User
        ) async throws -> EmptyResponse {

            guard exists else {
                return try await document.reference.setData(from: document)
            }

            var updateDictionary = try document.makedictionary(shouldExcludeEmpty: true)
            updateDictionary.removeValue(forKey: "photoURL")
            updateDictionary.removeValue(forKey: "headerUrl")
            updateDictionary.removeValue(forKey: "socialLinks")

            return try await document.reference.updateData(updateDictionary)
        }
    }
}
