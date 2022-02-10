import Combine
import DataLayer
import Foundation

public extension Domain.Usecase.Course {
    struct Delete: DeleteCourseUsecaseProtocol {

        let deleteCourseRepository: AnyRepository<Repositories.Course.Delete.R>
        let deleteStorageRepository: AnyRepository<Repositories.Storage.Delete.R>

        public init(
            deleteCourseRepository: AnyRepository<Repositories.Course.Delete.R> = AnyRepository(Repositories.Course.Delete()),
            deleteStorageRepository: AnyRepository<Repositories.Storage.Delete.R> = AnyRepository(Repositories.Storage.Delete())
        ) {
            self.deleteCourseRepository = deleteCourseRepository
            self.deleteStorageRepository = deleteStorageRepository
        }

        public func delete(id: String) async throws {
            try await self.deleteCourseRepository.request(
                parameters: .init(id: id)
            )
            try await self.deleteStorageRepository.request(
                parameters: .init(entry: .directory(path: FS.Collection.Courses.name + "/" + id))
            )
        }
    }
}

public protocol DeleteCourseUsecaseProtocol {
    func delete(id: String) async throws
}
