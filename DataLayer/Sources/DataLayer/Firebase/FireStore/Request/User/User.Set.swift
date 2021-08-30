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
        public var entry: Entry { FirestoreManager.db.document(path) }

        public init(parameters: Parameters) {
            self.parameters = parameters
        }

        public func reguest(
            useTestData: Bool,
            parameters: Parameters
        ) -> AnyPublisher<EmptyResponse, Error> {

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

            return userDocument.reference.exists()
                .flatMap {
                    setUserDocument(exists: $0, document: userDocument)
                }
                .eraseToAnyPublisher()

        }

        private func setUserDocument(
            exists: Bool,
            document: FS.Document.User
        ) -> AnyPublisher<EmptyResponse, Error> {

            guard exists else {
                return document.reference.setData(from: document)
            }

            do {
                var updateDictionary = try document.makedictionary(shouldExcludeEmpty: true)
                updateDictionary.removeValue(forKey: "photoURL")
                updateDictionary.removeValue(forKey: "headerUrl")
                updateDictionary.removeValue(forKey: "socialLinks")

                return document.reference.updateData(updateDictionary)

            } catch {
                return Fail<EmptyResponse, Error>(error: error).eraseToAnyPublisher()
            }
        }

    }
}
