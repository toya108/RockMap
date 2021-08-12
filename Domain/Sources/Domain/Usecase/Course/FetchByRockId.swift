
import Combine
import DataLayer

public extension Domain.Usecase.Course {
    struct FetchByRockId: UsecaseProtocol {
        public typealias Repository = Repositories.Course.FetchByRockId
        public typealias Mapper = Domain.Mapper.Course

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func fetchCourses(by rockId: String) -> AnyPublisher<[Domain.Entity.Course], Error> {
            self.toPublisher { promise in
                repository.request(parameters: .init(rockId: rockId)) { result in
                    switch result {
                        case let .success(response):
                            let entities = response.map { mapper.map(from: $0) }
                            promise(.success(entities))

                        case let .failure(error):
                            promise(.failure(error))
                    }
                }
            }
        }

    }
}
