
import Foundation

extension Domain.Entity {

    public struct User: EntityProtocol {
        var id: String
        var createdAt: Date
        var updatedAt: Date?
        var name: String
        var photoURL: URL?
        var socialLinks: [SocialLink] = []
        var introduction: String?
        var headerUrl: URL?
        var deleted: Bool = false

        struct SocialLink: Hashable {
            let linkType: SocialLinkType
            var link: String
        }

        enum SocialLinkType: String, CaseIterable {
            case facebook
            case twitter
            case instagram
            case other

            var placeHolder: String {
                switch self {
                    case .facebook, .twitter, .instagram:
                        return "@"

                    case .other:
                        return "ページURL"

                }
            }

            var urlBase: String {
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

            var httpsUrlBase: String {

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
