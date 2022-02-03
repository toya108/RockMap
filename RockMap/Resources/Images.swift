// swiftlint:disable force_unwrapping

import UIKit
import SwiftUI

extension Resources {
    struct Images {}
}

extension Resources.Images {
    enum System {
        case sliderHorizontal3
        case magnifyingglassCircle
        case magnifyingglassCircleFill
        case folderFill
        case cameraFill
        case personFill
        case personCircle
        case personCircleFill
        case mapCircle
        case mapCircleFill
        case mappinAndEllipse
        case xmarkCircleFill
        case plusCircleFill
        case plus
        case xmark
        case leafFill
        case bookMarkFill
        case bookMark
        case handPointUpLeftFill
        case docPlaintextFill
        case docPlaintext
        case triangleLefthalfFill
        case trash
        case squareAndPencil
        case gear
        case checkmarkShield
        case starCircle
        case arrowUpLeftSquare
        case chevronCompactLeft

        var name: String {
            switch self {
                case .sliderHorizontal3:
                    return "slider.horizontal.3"
                case .magnifyingglassCircle:
                    return "magnifyingglass.circle"
                case .magnifyingglassCircleFill:
                    return "magnifyingglass.circle.fill"
                case .folderFill:
                    return "folder.fill"
                case .cameraFill:
                    return "camera.fill"
                case .personFill:
                    return "person.fill"
                case .personCircle:
                    return "person.circle"
                case .personCircleFill:
                    return "person.circle.fill"
                case .mapCircle:
                    return "map.circle"
                case .mapCircleFill:
                    return "map.circle.fill"
                case .mappinAndEllipse:
                    return "mappin.and.ellipse"
                case .xmarkCircleFill:
                    return "xmark.circle.fill"
                case .plusCircleFill:
                    return "plus.circle.fill"
                case .plus:
                    return "plus"
                case .xmark:
                    return "xmark"
                case .leafFill:
                    return "leaf.fill"
                case .bookMarkFill:
                    return "bookmark.fill"
                case .bookMark:
                    return "bookmark"
                case .handPointUpLeftFill:
                    return "hand.point.up.left.fill"
                case .docPlaintextFill:
                    return "doc.plaintext.fill"
                case .docPlaintext:
                    return "doc.plaintext"
                case .triangleLefthalfFill:
                    return "triangle.lefthalf.fill"
                case .trash:
                    return "trash"
                case .squareAndPencil:
                    return "square.and.pencil"
                case .gear:
                    return "gear"
                case .checkmarkShield:
                    return "checkmark.shield"
                case .starCircle:
                    return "star.circle"
                case .arrowUpLeftSquare:
                    return "arrow.up.left.square"
                case .chevronCompactLeft:
                    return "chevron.compact.left"
            }
        }

        var uiImage: UIImage {
            UIImage(systemName: name)!.withRenderingMode(.alwaysTemplate)
        }

        var image: Image {
            Image(systemName: name)
        }
    }

    enum Assets {
        case back
        case rock
        case rockFill
        case noimage
        case penguinGudaGuda
        case spring
        case summer
        case autumn
        case winter
        case instagram
        case facebook
        case twitter
        case link
        case penguinRock
        case mountainBackGround

        var name: String {
            switch self {
                case .back:
                    return "back"
                case .rock:
                    return "rock"
                case .rockFill:
                    return "rock_fill"
                case .noimage:
                    return "no_image"
                case .penguinGudaGuda:
                    return "penguin_gudaguda"
                case .spring:
                    return "spring"
                case .summer:
                    return "summer"
                case .autumn:
                    return "autumn"
                case .winter:
                    return "winter"
                case .instagram:
                    return "instagram"
                case .facebook:
                    return "facebook"
                case .twitter:
                    return "twitter"
                case .link:
                    return "link"
                case .penguinRock:
                    return "penguin_rock"
                case .mountainBackGround:
                    return "mountain_back_ground"
            }
        }

        var uiImage: UIImage {
            UIImage(named: name)!
        }

        var image: Image {
            Image(name, bundle: nil)
        }
    }
}
