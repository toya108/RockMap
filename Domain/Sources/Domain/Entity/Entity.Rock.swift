
import Foundation

public extension Domain.Entity {

    struct Rock: AnyEntity {
        public var id: String
        public var createdAt: Date
        public var updatedAt: Date?
        public var parentPath: String
        public var name: String
        public var address: String
        public var prefecture: String
        public var location: GeoPoint
        public var seasons: Set<Season>
        public var lithology: Lithology
        public var desc: String
        public var registeredUserId: String
        public var headerUrl: URL?
        public var imageUrls: [URL]
    }

}

public extension Domain.Entity.Rock {

    enum Season: String, CaseIterable, Codable {
        case spring, summer, autumn, winter

        public var name: String {
            switch self {
                case .spring:
                    return "春"

                case .summer:
                    return "夏"

                case .autumn:
                    return "秋"

                case .winter:
                    return "冬"

            }
        }
    }

    enum Lithology: String, CaseIterable, Codable {
        case unKnown, granite, andesite, chert, limestone, tuff, sandstone

        public var name: String {
            switch self {
                case .unKnown:
                    return "不明"

                case .granite:
                    return "花崗岩"

                case .andesite:
                    return "安山岩"

                case .chert:
                    return "チャート"

                case .limestone:
                    return "石灰岩"

                case .tuff:
                    return "凝灰岩"

                case .sandstone:
                    return "砂岩"

            }
        }
    }
}
