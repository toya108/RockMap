
import Combine
import DataLayer

public extension Domain.Usecase.TotalClimbedNumber {
    struct ListenByCourseId: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.TotalClimbedNumber.ListenByCourseId
        public typealias Mapper = Domain.Mapper.TotalClimbedNumber

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func listen(
            useTestData: Bool,
            courseId: String,
            parantPath: String
        ) -> AnyPublisher<Domain.Entity.TotalClimbedNumber, Error> {
            self.repository.request(parameters: .init(parentPath: parantPath, courseId: courseId))
                .map { mapper.map(from: $0) }
                .eraseToAnyPublisher()
        }
    }
}
