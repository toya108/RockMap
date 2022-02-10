import Foundation

public extension Domain.Entity {
    struct Rock: AnyEntity {
        public var id: String
        public var createdAt: Date
        public var updatedAt: Date?
        public var parentPath: String
        public var name: String
        public var area: String?
        public var address: String
        public var prefecture: String
        public var location: GeoPoint
        public var seasons: [Season]
        public var lithology: Lithology
        public var desc: String
        public var registeredUserId: String
        public var headerUrl: URL?
        public var imageUrls: [URL]

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date? = nil,
            parentPath: String,
            name: String,
            area: String?,
            address: String,
            prefecture: String,
            location: Domain.Entity.GeoPoint,
            seasons: [Domain.Entity.Rock.Season],
            lithology: Domain.Entity.Rock.Lithology,
            desc: String,
            registeredUserId: String,
            headerUrl: URL? = nil,
            imageUrls: [URL]
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.parentPath = parentPath
            self.name = name
            self.area = area
            self.address = address
            self.prefecture = prefecture
            self.location = location
            self.seasons = seasons
            self.lithology = lithology
            self.desc = desc
            self.registeredUserId = registeredUserId
            self.headerUrl = headerUrl
            self.imageUrls = imageUrls
        }
    }
}

public extension Domain.Entity.Rock {
    enum Season: String, CaseIterable, Identifiable, Equatable {
        case spring, summer, autumn, winter

        public var id: String { self.rawValue }

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

    enum Lithology: String, CaseIterable, Identifiable {
        case unKnown, granite, andesite, chert, limestone, tuff, sandstone

        public var id: String { self.rawValue }

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
