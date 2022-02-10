import DataLayer
import Foundation
import Utilities

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
                shape: Set(other.shape.compactMap { Course.Shape(rawValue: $0) }),
                parentRockName: other.parentRockName,
                parentRockId: other.parentRockId,
                registeredUserId: other.registeredUserId,
                headerUrl: other.headerUrl,
                imageUrls: other.imageUrls
            )
        }

        public func reverse(to other: Domain.Entity.Course) -> FS.Document.Course {
            .init(
                id: other.id,
                parentPath: other.parentPath,
                createdAt: other.createdAt,
                updatedAt: other.updatedAt,
                name: other.name,
                desc: other.desc,
                grade: other.grade.rawValue,
                shape: Set(other.shape.map(\.rawValue)),
                parentRockName: other.parentRockName,
                parentRockId: other.parentRockId,
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
