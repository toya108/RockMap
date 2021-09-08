import UIKit

extension Entity.User.SocialLinkType {
    var icon: UIImage {
        switch self {
        case .facebook:
            return UIImage.AssetsImages.facebook

        case .twitter:
            return UIImage.AssetsImages.twitter

        case .instagram:
            return UIImage.AssetsImages.instagram

        case .other:
            return UIImage.AssetsImages.link
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
            return .black
        }
    }
}
