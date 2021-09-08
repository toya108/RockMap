import UIKit

extension CourseDetailViewController {
    enum SectionLayoutKind: CaseIterable {
        case headerImage
        case parentRock
        case title
        case registeredUser
        case buttons
        case climbedNumber
        case info
        case desc
        case images

        var headerTitle: String {
            switch self {
            case .climbedNumber:
                return "完登者数"

            case .info:
                return "基本情報"

            case .desc:
                return "詳細"

            case .images:
                return "画像"

            default:
                return ""
            }
        }

        var headerIdentifer: String {
            switch self {
            case .climbedNumber, .info, .images, .desc:
                return TitleSupplementaryView.className

            default:
                return ""
            }
        }

        var initialItems: [ItemKind] {
            switch self {
            case .parentRock:
                return [.parentRock]

            case .title:
                return [.title]

            case .registeredUser:
                return [.registeredUser]

            case .buttons:
                return [.buttons]

            case .climbedNumber:
                return [.climbedNumber]

            case .desc:
                return [.desc]

            default:
                return []
            }
        }
    }

    enum ItemKind: Hashable {
        case headerImage(URL)
        case buttons
        case title
        case registeredUser
        case climbedNumber
        case parentRock
        case shape(ValueCollectionViewCell.ValueCellStructure)
        case desc
        case image(URL)
        case noImage
    }
}
