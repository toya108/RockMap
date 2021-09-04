
import Combine
import DataLayer

public extension Domain.Usecase.User {
    struct Update: PassthroughUsecaseProtocol {
        public typealias Repository = Repositories.User.Update
        public typealias Mapper = Domain.Mapper.User

        var repository: Repository
        var mapper: Mapper

        public init(repository: Repository = .init(), mapper: Mapper = .init()) {
            self.repository = repository
            self.mapper = mapper
        }

        public func update(
            id: String,
            name: String?,
            introduction: String?,
            socialLinks: [Domain.Entity.User.SocialLink]?
        ) -> AnyPublisher<Void, Error> {

            let socialLinks: [FS.Document.User.SocialLink]? = {

                guard let socialLinks = socialLinks else { return nil }

                return socialLinks.map { .init(linkType: $0.linkType.rawValue, link: $0.link) }
            }()

            return repository.request(
                parameters: .init(
                    id: id,
                    name: name,
                    introduction: introduction,
                    socialLinks: socialLinks
                )
            )
            .map { _ in () }
            .eraseToAnyPublisher()
        }

    }
}
