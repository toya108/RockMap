import Foundation

public extension Domain.Entity {

    struct Image: AnyEntity {
        public let url: URL?
        public let fullPath: String?
        public let imageType: ImageType

        public init(
            url: URL,
            fullPath: String,
            imageType: Domain.Entity.Image.ImageType
        ) {
            self.url = url
            self.fullPath = fullPath
            self.imageType = imageType
        }

        public init(imageType: ImageType) {
            self.url = .init(string: "")
            self.fullPath = nil
            self.imageType = imageType
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
