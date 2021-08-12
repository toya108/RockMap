
import DataLayer
import Foundation

public extension Domain.Mapper {

    struct Course: MapperProtocol {

        public typealias Course = Domain.Entity.Course

        public init() {}

        public func map(from other: FS.Document.Course) -> Course {
            .init(
                id: other.id,
                parentPath: other.parentPath,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                name: other.name,
                desc: other.desc,
                grade: .init(rawValue: other.grade) ?? .q10,
                shape: other.shape.compactMap { Course.Shape(rawValue: $0) } ,
                parentRockName: other.parentRockName,
                parentRockId: other.parentRockId,
                registeredUserId: other.registeredUserId,
                headerUrl: other.headerUrl,
                imageUrls: other.imageUrls
            )
        }

    }

}
