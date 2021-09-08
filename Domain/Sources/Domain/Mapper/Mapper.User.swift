
import DataLayer
import Foundation

public extension Domain.Mapper {
    struct User: MapperProtocol {
        public typealias User = Domain.Entity.User

        public init() {}

        public func map(from other: FS.Document.User) -> User {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                name: other.name,
                photoURL: other.photoURL,
                socialLinks: other.socialLinks.compactMap {
                    guard
                        let linkType = User.SocialLinkType(rawValue: $0.linkType)
                    else {
                        return nil
                    }
                    return User.SocialLink(linkType: linkType, link: $0.link)
                },
                introduction: other.introduction,
                headerUrl: other.headerUrl,
                deleted: other.deleted
            )
        }

        public func reverse(to other: Domain.Entity.User) -> FS.Document.User {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                name: other.name,
                photoURL: other.photoURL,
                socialLinks: other.socialLinks.map {
                    .init(linkType: $0.linkType.rawValue, link: $0.link)
                },
                introduction: other.introduction,
                headerUrl: other.headerUrl,
                deleted: other.deleted
            )
        }
    }
}
