import Combine
import DataLayer
import Foundation

public protocol DeleteImageUsecaseProtocol: UsecaseProtocol {
    func delete(path: String) async throws
    init()
}

public extension Domain.Usecase.Image {
    struct Delete: DeleteImageUsecaseProtocol {
        let repository = AnyRepository(Repositories.Storage.Delete())

        public init() {}

        public func delete(path: String) async throws {
            try await self.repository.request(
                parameters: .init(path: path)
            )
        }
    }
}
