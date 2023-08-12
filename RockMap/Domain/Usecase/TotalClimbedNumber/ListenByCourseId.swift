import Combine
import DataLayer

public extension Domain.Usecase.TotalClimbedNumber {
    struct ListenByCourseId: ListenableUsecaseProtocol {
        public typealias Repository = Repositories.TotalClimbedNumber.ListenByCourseId
        public typealias Mapper = Domain.Mapper.TotalClimbedNumber

        let repository: Repository
        let mapper: Mapper

        public init(
            repository: Repository = Repositories.TotalClimbedNumber.ListenByCourseId(),
            mapper: Mapper = .init()
        ) {
            self.repository = repository
            self.mapper = mapper
        }

        public func listen(
            courseId: String
        ) -> AnyPublisher<Domain.Entity.TotalClimbedNumber, Error> {
            self.repository.request(
                parameters: .init(courseId: courseId)
            )
            .map { mapper.map(from: $0) }
            .eraseToAnyPublisher()
        }
    }
}
