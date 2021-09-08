
import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct FetchByUserId: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.FetchByUserId
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetch(by userId: String) -> AnyPublisher<[Domain.Entity.ClimbRecord], Error> {
            self.repository.request(parameters: .init(userId: userId))
                .map { responses -> [Domain.Entity.ClimbRecord] in
                    responses.map { mapper.map(from: $0) }
                }
                .eraseToAnyPublisher()
        }
    }
}
