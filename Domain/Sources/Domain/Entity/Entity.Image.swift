import Foundation

public extension Domain.Entity {

    struct Image: AnyEntity {
        public var url: URL
        public var fullPath: String
        public var imageType: ImageType
    }
}

public extension Domain.Entity.Image {

    enum ImageType: Hashable {
        case header
        case normal
        case icon

        public var limit: Int {
            switch self {
                case .header, .icon:
                    return 1

                default:
                    return 10
            }
        }

        public var typeName: String {
            switch self {
                case .header:
                    return "header"

                case .normal:
                    return "normal"

                case .icon:
                    return "icon"
            }
        }
    }
}
