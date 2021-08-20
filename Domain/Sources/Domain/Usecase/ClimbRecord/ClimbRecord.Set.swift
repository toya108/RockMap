import Combine
import DataLayer

public extension Domain.Usecase.ClimbRecord {
    struct Set: UsecaseProtocol {
        public typealias Repository = Repositories.ClimbRecord.Set
        public typealias Mapper = Domain.Mapper.ClimbRecord

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func set(climbRecord: Domain.Entity.ClimbRecord) -> AnyPublisher<Void, Error> {
            self.toPublisher { promise in

                let document = mapper.reverse(to: climbRecord)

                repository.request(parameters: .init(climbRecord: document)) { result in
                    switch result {
                        case .success:
                            promise(.success(()))

                        case let .failure(error):
                            promise(.failure(error))
                    }
                }
            }
        }

    }
}
