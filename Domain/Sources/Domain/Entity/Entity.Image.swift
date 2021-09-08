import Foundation

public extension Domain.Entity {
    struct Image: AnyEntity {
        public let url: URL?
        public let fullPath: String?

        public init(
            url: URL,
            fullPath: String
        ) {
            self.url = url
            self.fullPath = fullPath
        }

        public init() {
            self.url = .init(string: "")
            self.fullPath = nil
        }
    }
}

public extension Domain.Entity.Image {
    enum ImageType: Hashable {
        case header
        case normal
        case icon
        case unhandle

        public var limit: Int {
            switch self {
            case .header, .icon:
                return 1

            case .unhandle:
                return 0

            case .normal:
                return 10
            }
        }

        public var name: String {
            switch self {
            case .header:
                return "header"

            case .normal:
                return "normal"

            case .icon:
                return "icon"

            case .unhandle:
                return ""
            }
        }
    }
}
