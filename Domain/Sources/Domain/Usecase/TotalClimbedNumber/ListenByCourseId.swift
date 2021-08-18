
import Combine
import DataLayer

public extension Domain.Usecase.TotalClimbedNumber {
    struct ListenByCourseId: UsecaseProtocol, Listenable {

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
            Domain.Usecase.ListenPublisher(
                repository: repository,
                useTestData: useTestData,
                paremeters: .init(parentPath: parantPath, courseId: courseId)
            )
            .compactMap { response -> Domain.Entity.TotalClimbedNumber? in

                guard let document = response.first else { return nil }

                return self.mapper.map(from: document)
            }
            .eraseToAnyPublisher()
        }
    }
}
