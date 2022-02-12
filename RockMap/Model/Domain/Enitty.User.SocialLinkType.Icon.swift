import UIKit

extension Entity.User.SocialLinkType {
    var icon: Resources.Images.Assets {
        switch self {
            case .facebook:
                return Resources.Images.Assets.facebook

            case .twitter:
                return Resources.Images.Assets.twitter

            case .instagram:
                return Resources.Images.Assets.instagram

            case .other:
                return Resources.Images.Assets.link
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
