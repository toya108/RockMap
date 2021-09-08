import UIKit

extension Entity.Rock.Season {
    var iconImage: UIImage {
        switch self {
        case .spring:
            return UIImage.AssetsImages.spring

        case .summer:
            return UIImage.AssetsImages.summer

        case .autumn:
            return UIImage.AssetsImages.autumn

        case .winter:
            return UIImage.AssetsImages.winter
        }
    }
}
