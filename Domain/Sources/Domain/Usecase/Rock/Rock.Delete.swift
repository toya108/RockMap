import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Rock {
    struct Delete: DeleteRockUsecaseProtocol {
        let deleteRockRepository: AnyRepository<Repositories.Rock.Delete.R>
        let deleteStorageRepository: AnyRepository<Repositories.Storage.Delete.R>

        public init(
            deleteRockRepository: AnyRepository<Repositories.Rock.Delete.R> = AnyRepository(Repositories.Rock.Delete()),
            deleteStorageRepository: AnyRepository<Repositories.Storage.Delete.R> = AnyRepository(Repositories.Storage.Delete())
        ) {
            self.deleteRockRepository = deleteRockRepository
            self.deleteStorageRepository = deleteStorageRepository
        }

        public func delete(id: String) async throws {
            try await self.deleteRockRepository.request(
                parameters: .init(id: id)
            )
            try await self.deleteStorageRepository.request(
                parameters: .init(entry: .directory(path: FS.Collection.Rocks.name + "/" + id))
            )
        }
    }
}

public protocol DeleteRockUsecaseProtocol {
    func delete(id: String) async throws
}
