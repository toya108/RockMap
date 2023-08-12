import Combine
import DataLayer
import Foundation

public protocol DeleteImageUsecaseProtocol {
    func delete(path: String, isFile: Bool) async throws
    init()
}

public extension Domain.Usecase.Image {
    struct Delete: DeleteImageUsecaseProtocol {
        let repository = AnyRepository(Repositories.Storage.Delete())

        public init() {}

        public func delete(path: String, isFile: Bool = true) async throws {
            try await self.repository.request(
                parameters: .init(entry: isFile ? .file(path: path) : .directory(path: path))
            )
        }
    }
}
