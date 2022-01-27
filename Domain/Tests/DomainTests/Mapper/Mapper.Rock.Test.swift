@testable import Domain
import DataLayer
import XCTest

final class RockMapperTests: XCTestCase {

    private let mapper = Domain.Mapper.Rock()

    private let rockId = UUID().uuidString
    private let userId = UUID().uuidString
    private let createdAt = Date(timeIntervalSinceNow: 2.0)
    private let updatedAt = Date(timeIntervalSinceNow: 1.0)
    private let dummyURL = URL(string: "https://www.google.com/")!

    func testMapper() {

        let document = FS.Document.Rock(
            id: rockId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            parentPath: "users/" + userId,
            name: "日陰岩",
            address: "東京都千代田区",
            prefecture: "東京都",
            location: .init(latitude: 35.810537, longitude: 139.473032),
            seasons: Set(["summer"]),
            lithology: "chert",
            area: "御岳",
            desc: "rockrockrock",
            registeredUserId: userId,
            headerUrl: dummyURL,
            imageUrls: [dummyURL],
            tokenMap: [
                "日陰": true,
                "陰岩": true
            ]
        )

        let entity = mapper.map(from: document)

        XCTAssertEqual(entity.id, rockId)
        XCTAssertEqual(entity.createdAt, createdAt)
        XCTAssertEqual(entity.updatedAt, updatedAt)
        XCTAssertEqual(entity.parentPath, "users/" + userId)
        XCTAssertEqual(entity.name, "日陰岩")
        XCTAssertEqual(entity.address, "東京都千代田区")
        XCTAssertEqual(entity.prefecture, "東京都")
        XCTAssertEqual(entity.location, .init(latitude: 35.810537, longitude: 139.473032))
        XCTAssertEqual(entity.seasons, Set([.summer]))
        XCTAssertEqual(entity.lithology, .chert)
        XCTAssertEqual(entity.area, "御岳")
        XCTAssertEqual(entity.desc, "rockrockrock")
        XCTAssertEqual(entity.registeredUserId, userId)
        XCTAssertEqual(entity.headerUrl, dummyURL)
        XCTAssertEqual(entity.imageUrls, [dummyURL])
    }

    func testReverse() {
        let entity = Domain.Entity.Rock(
            id: rockId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            parentPath: "users/" + userId,
            name: "日陰岩",
            area: "御岳",
            address: "東京都千代田区",
            prefecture: "東京都",
            location: .init(latitude: 35.810537, longitude: 139.473032),
            seasons: Set([.summer]),
            lithology: .chert,
            desc: "rockrockrock",
            registeredUserId: userId,
            headerUrl: dummyURL,
            imageUrls: [dummyURL]
        )

        let document = mapper.reverse(to: entity)

        XCTAssertEqual(document.id, rockId)
        XCTAssertEqual(document.createdAt, createdAt)
        XCTAssertEqual(document.updatedAt, updatedAt)
        XCTAssertEqual(document.parentPath, "users/" + userId)
        XCTAssertEqual(document.name, "日陰岩")
        XCTAssertEqual(document.address, "東京都千代田区")
        XCTAssertEqual(document.prefecture, "東京都")
        XCTAssertEqual(document.location, .init(latitude: 35.810537, longitude: 139.473032))
        XCTAssertEqual(document.seasons, Set(["summer"]))
        XCTAssertEqual(document.lithology, "chert")
        XCTAssertEqual(document.area, "御岳")
        XCTAssertEqual(document.desc, "rockrockrock")
        XCTAssertEqual(document.registeredUserId, userId)
        XCTAssertEqual(document.headerUrl, dummyURL)
        XCTAssertEqual(document.imageUrls, [dummyURL])
    }

}
