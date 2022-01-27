import DataLayer
import Foundation
import Utilities

public extension Domain.Mapper {
    struct Rock: MapperProtocol {
        public typealias Rock = Domain.Entity.Rock

        public init() {}

        public func map(from other: FS.Document.Rock) -> Rock {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                parentPath: other.parentPath,
                name: other.name,
                area: other.area,
                address: other.address,
                prefecture: other.prefecture,
                location: .init(
                    latitude: other.location.latitude,
                    longitude: other.location.longitude
                ),
                seasons: Set(other.seasons.compactMap { .init(rawValue: $0) }),
                lithology: .init(rawValue: other.lithology) ?? .unKnown,
                desc: other.desc,
                registeredUserId: other.registeredUserId,
                headerUrl: other.headerUrl,
                imageUrls: other.imageUrls
            )
        }

        public func reverse(to other: Rock) -> FS.Document.Rock {
            .init(
                id: other.id,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                parentPath: other.parentPath,
                name: other.name,
                address: other.address,
                prefecture: other.prefecture,
                location: .init(
                    latitude: other.location.latitude,
                    longitude: other.location.longitude
                ),
                seasons: Set(other.seasons.map(\.rawValue)),
                lithology: other.lithology.rawValue,
                area: other.area,
                desc: other.desc,
                registeredUserId: other.registeredUserId,
                headerUrl: other.headerUrl,
                imageUrls: other.imageUrls,
                tokenMap: NGramGenerator.makeNGram(input: other.name, n: 2)
                    .reduce(into: [String: Bool]()) {
                        $0[$1] = true
                    }
            )
        }
    }
}
