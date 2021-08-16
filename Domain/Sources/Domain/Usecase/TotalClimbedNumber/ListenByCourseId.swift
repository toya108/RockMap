
import Combine
import DataLayer

public extension Domain.Usecase.TotalClimbedNumber {
    class FetchById: UsecaseProtocol, Listenable {
        public typealias Repository = Repositories.TotalClimbedNumber.ListenByCourseId
        public typealias Mapper = Domain.Mapper.TotalClimbedNumber

        var repository: Repository
        var mapper: Mapper

        var registration: FSListenerRegistration?

        required public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func listen(parentPath: String, courseId: String) -> AnyPublisher<Domain.Entity.TotalClimbedNumber, Error> {
            self.toPublisher { [weak self] promise in

                guard let self = self else { return }

                self.registration = self.repository.listen(
                    parameters: .init(parentPath: parentPath, courseId: courseId)
                ) { [weak self] result in

                    guard let self = self else { return }

                    switch result {
                        case let .success(response):

                            guard let document = response.first else { return }

                            let entity = self.mapper.map(from: document)
                            promise(.success(entity))

                        case let .failure(error):
                            promise(.failure(error))
                    }
                }
            }
        }
    }
}
