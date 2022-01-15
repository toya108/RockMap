import UIKit

extension RockDetailViewController {
    enum SectionLayoutKind: CaseIterable {
        case header
        case title
        case registeredUser
        case info
        case courses
        case desc
        case map
        case images

        var headerTitle: String {
            switch self {
            case .desc:
                return "詳細"

            case .map:
                return "岩の位置"

            case .info:
                return "基本情報"

            case .courses:
                return "課題一覧"

            case .images:
                return "画像"

            default:
                return ""
            }
        }

        var headerIdentifer: String {
            switch self {
            case .desc, .map, .info, .courses, .images:
                return TitleSupplementaryView.className

            default:
                return ""
            }
        }
    }

    enum ItemKind: Hashable {
        case header(URL)
        case title(String)
        case registeredUser(user: Entity.User)
        case desc(String)
        case season(Set<Entity.Rock.Season>)
        case lithology(Entity.Rock.Lithology)
        case erea(String)
        case containGrade([Entity.Course.Grade: Int])
        case map(LocationManager.LocationStructure)
        case courses(Entity.Course)
        case nocourse
        case image(URL)
        case noImage
    }
}
