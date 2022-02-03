import UIKit

extension Entity.User.SocialLinkType {
    var icon: UIImage {
        switch self {
            case .facebook:
                return Resources.Images.Assets.facebook.uiImage

            case .twitter:
                return Resources.Images.Assets.twitter.uiImage

            case .instagram:
                return Resources.Images.Assets.instagram.uiImage

            case .other:
                return Resources.Images.Assets.link.uiImage
        }
    }

    var color: UIColor {
        switch self {
            case .facebook:
                return UIColor.Pallete.facebook

            case .twitter:
                return UIColor.Pallete.twitter

            case .instagram:
                return UIColor.Pallete.instagram

            case .other:
                return .label
        }
    }
}
