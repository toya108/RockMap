import UIKit
import SwiftUI

extension Entity.Rock.Season {
    var iconImage: UIImage {
        switch self {
            case .spring:
                return Resources.Images.Assets.spring.uiImage
                
            case .summer:
                return Resources.Images.Assets.summer.uiImage
                
            case .autumn:
                return Resources.Images.Assets.autumn.uiImage
                
            case .winter:
                return Resources.Images.Assets.winter.uiImage
        }
    }

    var icon: Image {
        switch self {
            case .spring:
                return Resources.Images.Assets.spring.image

            case .summer:
                return Resources.Images.Assets.summer.image

            case .autumn:
                return Resources.Images.Assets.autumn.image

            case .winter:
                return Resources.Images.Assets.winter.image
        }
    }
}
