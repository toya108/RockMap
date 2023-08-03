@testable import RockMap
import DataLayer
import XCTest

final class CourseMapperTests: XCTestCase {

    private let mapper = Domain.Mapper.Course()

    private let courseId = UUID().uuidString
    private let userId = UUID().uuidString
    private let rockId = UUID().uuidString
    private let createdAt = Date(timeIntervalSinceNow: 2.0)
    private let updatedAt = Date(timeIntervalSinceNow: 1.0)
    private let dummyURL = URL(string: "https://www.google.com/")!

    func testMapper() {

        let document = FS.Document.Course(
            id: courseId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "峰の夕",
            desc: "rockrockrock",
            grade: "10q",
            shape: Set(["overhang"]),
            parentRockName: "日陰岩",
            parentRockId: rockId,
            registeredUserId: userId,
            headerUrl: dummyURL,
            imageUrls: [dummyURL],
            tokenMap: [
                "峰の": true,
                "の夕": true
            ]
        )

        let entity = mapper.map(from: document)

        XCTAssertEqual(entity.id, courseId)
        XCTAssertEqual(entity.createdAt, createdAt)
        XCTAssertEqual(entity.updatedAt, updatedAt)
        XCTAssertEqual(entity.name, "峰の夕")

        XCTAssertEqual(entity.desc, "rockrockrock")
        XCTAssertEqual(entity.grade, .q10)
        XCTAssertEqual(entity.shape, Set([.overhang]))
        XCTAssertEqual(entity.parentRockName, "日陰岩")
        XCTAssertEqual(entity.parentRockId, rockId)
        XCTAssertEqual(entity.registeredUserId, userId)
        XCTAssertEqual(entity.headerUrl, dummyURL)
        XCTAssertEqual(entity.imageUrls, [dummyURL])
    }

    func testReverse() {

        let entity = Domain.Entity.Course(
            id: courseId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "峰の夕",
            desc: "rockrockrock",
            grade: .q10,
            shape: Set([.overhang]),
            parentRockName: "日陰岩",
            parentRockId: rockId,
            registeredUserId: userId,
            headerUrl: dummyURL,
            imageUrls: [dummyURL]
        )

        let document = mapper.reverse(to: entity)

        XCTAssertEqual(document.id, courseId)
        XCTAssertEqual(document.createdAt, createdAt)
        XCTAssertEqual(document.updatedAt, updatedAt)
        XCTAssertEqual(document.parentPath, "")
        XCTAssertEqual(document.name, "峰の夕")
        XCTAssertEqual(document.desc, "rockrockrock")
        XCTAssertEqual(document.grade, "q10")
        XCTAssertEqual(document.shape, Set(["overhang"]))
        XCTAssertEqual(document.parentRockName, "日陰岩")
        XCTAssertEqual(document.parentRockId, rockId)
        XCTAssertEqual(document.registeredUserId, userId)
        XCTAssertEqual(document.headerUrl, dummyURL)
        XCTAssertEqual(document.imageUrls, [dummyURL])
    }

}
