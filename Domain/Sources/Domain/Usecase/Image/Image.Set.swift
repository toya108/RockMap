import Combine
import DataLayer
import Foundation

public protocol SetImageUsecaseProtocol {
    func set(path: String, data: Data) async throws
    init()
}

public extension Domain.Usecase.Image {
    struct Set: SetImageUsecaseProtocol {
        let repository = AnyRepository(Repositories.Storage.Set())

        public init() {}

        public func set(path: String, data: Data) async throws {
            try await self.repository.request(
                parameters: .init(path: path, data: data)
            )
        }
    }
}
