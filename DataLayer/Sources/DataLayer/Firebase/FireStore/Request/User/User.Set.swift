import Combine
import Foundation

public extension FS.Request.User {
    struct Set: FirestoreRequestProtocol {
        public typealias Entry = FSDocument

        public typealias Collection = FS.Collection.Users
        public typealias Response = EmptyResponse
        public struct Parameters: Codable {
            let user: FS.Document.User

            public init(user: FS.Document.User) {
                self.user = user
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
            let user = parameters.user
            let exists = try await user.reference.exists()
            return try await setUserDocument(exists: exists, document: user)
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
