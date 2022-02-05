import Foundation

public extension Domain.Entity {
    struct Course: AnyEntity {
        public var id: String
        public var parentPath: String
        public var createdAt = Date()
        public var updatedAt: Date?
        public var name: String
        public var desc: String
        public var grade: Grade
        public var shape: Set<Shape>
        public var parentRockName: String
        public var parentRockId: String
        public var registeredUserId: String
        public var headerUrl: URL?
        public var imageUrls: [URL] = []

        public init(
            id: String,
            parentPath: String,
            createdAt: Date,
            updatedAt: Date?,
            name: String,
            desc: String,
            grade: Domain.Entity.Course.Grade,
            shape: Set<Domain.Entity.Course.Shape>,
            parentRockName: String,
            parentRockId: String,
            registeredUserId: String,
            headerUrl: URL?,
            imageUrls: [URL]
        ) {
            self.id = id
            self.parentPath = parentPath
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.name = name
            self.desc = desc
            self.grade = grade
            self.shape = shape
            self.parentRockName = parentRockName
            self.parentRockId = parentRockId
            self.registeredUserId = registeredUserId
            self.headerUrl = headerUrl
            self.imageUrls = imageUrls
        }
    }
}

public extension Domain.Entity.Course {
    enum Grade: String, CaseIterable, Identifiable {
        case d5, d4, d3, d2, d1, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10

        public var id: String { self.rawValue }

        public var name: String {
            switch self {
            case .d5:
                return "5段"

            case .d4:
                return "4段"

            case .d3:
                return "3段"

            case .d2:
                return "2段"

            case .d1:
                return "初段"

            case .q1:
                return "1級"

            case .q2:
                return "2級"

            case .q3:
                return "3級"

            case .q4:
                return "4級"

            case .q5:
                return "5級"

            case .q6:
                return "6級"

            case .q7:
                return "7級"

            case .q8:
                return "8級"

            case .q9:
                return "9級"

            case .q10:
                return "10級"
            }
        }
    }

    enum Shape: String, CaseIterable, Identifiable {
        case roof, slab, face, overhang, kante, lip

        public var id: String { self.rawValue }

        public var name: String {
            switch self {
            case .roof:
                return "ルーフ"

            case .slab:
                return "スラブ"

            case .face:
                return "垂壁"

            case .overhang:
                return "オーバーハング"

            case .kante:
                return "カンテ"

            case .lip:
                return "リップ"
            }
        }
    }
}
