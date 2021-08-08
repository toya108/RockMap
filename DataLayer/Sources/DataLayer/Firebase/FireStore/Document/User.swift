
import Foundation
import FirebaseFirestoreSwift

extension FS.Document {
    
    struct User: DocumentProtocol {
        
        var collection: CollectionProtocol.Type { FS.Collection.Users.self }

        var id: String
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String = ""
        var name: String
        @ExplicitNull var photoURL: URL?
        var socialLinks: [SocialLink] = []
        @ExplicitNull var introduction: String?
        @ExplicitNull var headerUrl: URL?
        var deleted: Bool = false
        
        struct SocialLink: Hashable, Codable {
            let linkType: SocialLinkType
            var link: String
        }

        enum SocialLinkType: String, CaseIterable, Codable {
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

extension Array where Element == FS.Document.User.SocialLink {

    func getLink(
        type: FS.Document.User.SocialLinkType
    ) -> FS.Document.User.SocialLink? {
        return self.first(where: { $0.linkType == type })
    }

    mutating func updateLink(
        type: FS.Document.User.SocialLinkType,
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
