import UIKit

enum LocationSelectButtonState {
    case standby
    case selecting

    var image: UIImage {
        switch self {
        case .standby:
            return UIImage.SystemImages.plus

        case .selecting:
            return UIImage.SystemImages.handPointUpLeftFill
        }
    }

    var backGroundColor: UIColor {
        switch self {
        case .standby:
            return .tertiarySystemBackground

        case .selecting:
            return UIColor.Pallete.primaryGreen
        }
    }

    var tintColor: UIColor {
        switch self {
        case .standby:
            return UIColor.Pallete.primaryGreen

        case .selecting:
            return .tertiarySystemBackground
        }
    }
}
