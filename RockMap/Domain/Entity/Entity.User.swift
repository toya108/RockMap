import Foundation

public extension Domain.Entity {
    struct User: AnyEntity {
        public var id: String
        public var createdAt: Date
        public var updatedAt: Date?
        public var name: String
        public var photoURL: URL?
        public var socialLinks: [SocialLink] = []
        public var introduction: String?
        public var headerUrl: URL?
        public var deleted: Bool = false

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date? = nil,
            name: String,
            photoURL: URL? = nil,
            socialLinks: [Domain.Entity.User.SocialLink] = [],
            introduction: String? = nil,
            headerUrl: URL? = nil,
            deleted: Bool = false
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.photoURL = photoURL
            self.socialLinks = socialLinks
            self.introduction = introduction
            self.headerUrl = headerUrl
            self.deleted = deleted
        }

        public struct SocialLink: Hashable {
            public let linkType: SocialLinkType
            public var link: String

            public init(linkType: SocialLinkType, link: String) {
                self.linkType = linkType
                self.link = link
            }
        }

        public enum SocialLinkType: String, CaseIterable, Identifiable {
            case facebook
            case twitter
            case instagram
            case other

            public var id: String {
                self.rawValue
            }

            public var placeHolder: String {
                switch self {
                case .facebook, .twitter, .instagram:
                    return "@"

                case .other:
                    return "ページURL"
                }
            }

            public var urlBase: String {
                switch self {
                case .twitter:
                    return "twitter://user?screen_name="

                case .facebook:
                    return "fb://profile/"

                case .instagram:
                    return "instagram://"

                case .other:
                    return ""
                }
            }

            public var httpsUrlBase: String {
                switch self {
                case .twitter:
                    return "https://twitter.com/"

                case .facebook:
                    return "https://www.facebook.com/"

                case .instagram:
                    return "https://www.instagram.com/"

                case .other:
                    return ""
                }
            }
        }
    }
}

public extension Domain.Entity.User {
    static var dummy: Self {
        .init(id: UUID().uuidString, createdAt: Date(), name: "")
    }
}

public extension Array where Element == Domain.Entity.User.SocialLink {
    func getLink(
        type: Domain.Entity.User.SocialLinkType
    ) -> Domain.Entity.User.SocialLink? {
        self.first(where: { $0.linkType == type })
    }

    mutating func updateLink(
        type: Domain.Entity.User.SocialLinkType,
        link: String
    ) {
        guard
            let index = self.firstIndex(where: { $0.linkType == type })
        else {
            return
        }

        self[index].link = link
    }
}
