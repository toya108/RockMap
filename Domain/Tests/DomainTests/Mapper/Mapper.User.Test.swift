@testable import Domain
import DataLayer
import XCTest

final class UserMapperTests: XCTestCase {

    private let mapper = Domain.Mapper.User()

    private let createdAt = Date(timeIntervalSinceNow: 2.0)
    private let updatedAt = Date(timeIntervalSinceNow: 1.0)
    private let dummyURL = URL(string: "https://www.google.com/")!

    func testMapper() {

        let document = FS.Document.User(
            id: "123456789",
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "taro",
            photoURL: dummyURL,
            socialLinks: [
                .init(linkType: "twitter", link: "aaaa")
            ],
            introduction: "hello",
            headerUrl: dummyURL,
            deleted: false,
            tokenMap: [:]
        )

        let entity = mapper.map(from: document)

        XCTAssertEqual(entity.id, "123456789")
        XCTAssertEqual(entity.createdAt, createdAt)
        XCTAssertEqual(entity.updatedAt, updatedAt)
        XCTAssertEqual(entity.name, "taro")
        XCTAssertEqual(entity.photoURL, dummyURL)
        XCTAssertEqual(
            entity.socialLinks,
            [Domain.Entity.User.SocialLink(linkType: .twitter, link: "aaaa")]
        )
        XCTAssertEqual(entity.introduction, "hello")
        XCTAssertEqual(entity.headerUrl, dummyURL)
        XCTAssertEqual(entity.deleted, false)
    }

    func testMapperWithSocialLinkType() {

        var document = FS.Document.User(
            id: "123456789",
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "taro",
            photoURL: dummyURL,
            socialLinks: [
                .init(linkType: "twitter", link: "aaaa")
            ],
            introduction: "hello",
            headerUrl: dummyURL,
            deleted: false,
            tokenMap: [
                "ta": true,
                "ar": true,
                "ro": true
            ]
        )

        XCTAssertEqual(mapper.map(from: document).socialLinks.first!.linkType, .twitter)

        document.socialLinks = [.init(linkType: "instagram", link: "aaaa")]

        XCTAssertEqual(mapper.map(from: document).socialLinks.first!.linkType, .instagram)

        document.socialLinks = [.init(linkType: "facebook", link: "aaaa")]

        XCTAssertEqual(mapper.map(from: document).socialLinks.first!.linkType, .facebook)

        document.socialLinks = [.init(linkType: "", link: "aaaa")]

        XCTAssertEqual(mapper.map(from: document).socialLinks.first!.linkType, .other)
    }

    func testReverse() {

        let entity = Domain.Entity.User(
            id: "123456789",
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "taro",
            photoURL: dummyURL,
            socialLinks: [.init(linkType: .facebook, link: "aaaa")],
            introduction: "hello",
            headerUrl: dummyURL,
            deleted: false
        )

        let document = mapper.reverse(to: entity)

        XCTAssertEqual(document.id, "123456789")
        XCTAssertEqual(document.createdAt, createdAt)
        XCTAssertEqual(document.updatedAt, updatedAt)
        XCTAssertEqual(document.name, "taro")
        XCTAssertEqual(document.photoURL, dummyURL)
        XCTAssertEqual(
            document.socialLinks,
            [FS.Document.User.SocialLink(linkType: "facebook", link: "aaaa")]
        )
        XCTAssertEqual(document.introduction, "hello")
        XCTAssertEqual(document.headerUrl, dummyURL)
        XCTAssertEqual(document.deleted, false)
    }

    func testReverseWithSocialLinkType() {

        var entity = Domain.Entity.User(
            id: "123456789",
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: "taro",
            photoURL: dummyURL,
            socialLinks: [.init(linkType: .twitter, link: "aaaa")],
            introduction: "hello",
            headerUrl: dummyURL,
            deleted: false
        )

        XCTAssertEqual(mapper.reverse(to: entity).socialLinks.first!.linkType, "twitter")

        entity.socialLinks = [.init(linkType: .instagram, link: "aaaa")]

        XCTAssertEqual(mapper.reverse(to: entity).socialLinks.first!.linkType, "instagram")

        entity.socialLinks = [.init(linkType: .facebook, link: "aaaa")]

        XCTAssertEqual(mapper.reverse(to: entity).socialLinks.first!.linkType, "facebook")

        entity.socialLinks = [.init(linkType: .other, link: "aaaa")]

        XCTAssertEqual(mapper.reverse(to: entity).socialLinks.first!.linkType, "other")
    }
}
