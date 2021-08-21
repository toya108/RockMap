
import Foundation

extension Domain.Entity {

    public struct User: AnyEntity {
        public var id: String
        public var createdAt: Date
        public var updatedAt: Date?
        public var name: String
        public var photoURL: URL?
        public var socialLinks: [SocialLink] = []
        public var introduction: String?
        public var headerUrl: URL?
        public var deleted: Bool = false

        public struct SocialLink: Hashable {
            public let linkType: SocialLinkType
            public var link: String

            public init(linkType: SocialLinkType, link: String) {
                self.linkType = linkType
                self.link = link
            }
        }

        public enum SocialLinkType: String, CaseIterable {
            case facebook
            case twitter
            case instagram
            case other

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

public extension Array where Element == Domain.Entity.User.SocialLink {

    func getLink(
        type: Domain.Entity.User.SocialLinkType
    ) -> Domain.Entity.User.SocialLink? {
        return self.first(where: { $0.linkType == type })
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
