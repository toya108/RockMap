import Combine
import DataLayer

public extension Domain.Usecase.TotalClimbedNumber {
    struct ListenByCourseId: PassthroughUsecaseProtocol {
        public typealias Repository = AnyRepository<Repositories.TotalClimbedNumber.ListenByCourseId.R>
        public typealias Mapper = Domain.Mapper.TotalClimbedNumber

        var repository: Repository
        var mapper: Mapper

        public init(
            repository: Repository = AnyRepository(Repositories.TotalClimbedNumber.ListenByCourseId()),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func listen(
            useTestData: Bool,
            courseId: String,
            parantPath: String
        ) async throws -> Domain.Entity.TotalClimbedNumber {
            let document = try await self.repository.request(
                parameters: .init(
                    parentPath: parantPath,
                    courseId: courseId
                )
            )
            return mapper.map(from: document)
        }
    }
}
