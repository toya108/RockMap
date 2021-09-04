
import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct FetchByCourseId: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.FetchByCourseId
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by courseId: String) -> AnyPublisher<[Domain.Entity.ClimbRecord], Error> {
            repository.request(parameters: .init(courseId: courseId))
                .map { responses -> [Domain.Entity.ClimbRecord] in
                    responses.map { mapper.map(from: $0) }
                }
                .eraseToAnyPublisher()
        }

    }
}
