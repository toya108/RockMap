
import DataLayer
import Foundation

public extension Domain.Mapper {

    struct Image: MapperProtocol {

        public typealias Image = Domain.Entity.Image

        public init() {}

        public func map(from other: FireStorage.Image) -> Image {
            .init(
                url: other.url,
                fullPath: other.fullPath
            )
        }
    }

}
