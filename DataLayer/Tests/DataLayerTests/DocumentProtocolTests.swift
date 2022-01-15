import FirebaseFirestore
import FirebaseTestHelper
import XCTest

@testable import DataLayer

final class DocumentProtocolTests: XCTestCase {
    override func setUp() {
        super.setUp()
        FirebaseTestHelper.setupFirebaseApp()
    }

    override func tearDown() {
        super.tearDown()
        FirebaseTestHelper.deleteFirebaseApp()
    }

    private let userDocument = FS.Document.User(
        id: UUID().uuidString,
        createdAt: Date(),
        updatedAt: nil,
        name: "jiro",
        photoURL: nil,
        socialLinks: [],
        introduction: nil,
        headerUrl: nil,
        deleted: false
    )

    func testUserReference() throws {
        XCTAssertEqual(
            FS.Collection.Users.name + "/" + self.userDocument.id,
            self.userDocument.reference.path
        )
    }

    func testRockReference() throws {
        let rockDocument = FS.Document.Rock(
            id: UUID().uuidString,
            createdAt: Date(),
            updatedAt: nil,
            parentPath: self.userDocument.reference.path,
            name: "aaa",
            address: "北海道",
            prefecture: "北海道",
            location: .init(latitude: 0.0, longitude: 0.0),
            seasons: [],
            lithology: "chert",
            erea: "御岳",
            desc: "aaa",
            registeredUserId: self.userDocument.id,
            headerUrl: nil,
            imageUrls: []
        )

        let expectPath = [
            FS.Collection.Users.name,
            self.userDocument.id,
            FS.Collection.Rocks.name,
            rockDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            rockDocument.reference.path
        )
    }

    func testCourseReference() throws {
        let courseDocument = FS.Document.Course(
            id: UUID().uuidString,
            parentPath: self.userDocument.reference.path,
            createdAt: Date(),
            updatedAt: nil,
            name: "aaa",
            desc: "aaa",
            grade: "d1",
            shape: [],
            parentRockName: "rock",
            parentRockId: UUID().uuidString,
            registeredUserId: self.userDocument.id,
            headerUrl: nil,
            imageUrls: []
        )
        let expectPath = [
            FS.Collection.Users.name,
            self.userDocument.id,
            FS.Collection.Courses.name,
            courseDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            courseDocument.reference.path
        )
    }

    func testClimbRecoedReference() throws {
        let dummyDocumentReference = Firestore.firestore().collection("aaa").document()

        let climbRecordDocument = FS.Document.ClimbRecord(
            id: UUID().uuidString,
            registeredUserId: self.userDocument.id,
            parentCourseId: dummyDocumentReference.documentID,
            parentCourseReference: dummyDocumentReference,
            totalNumberReference: dummyDocumentReference,
            createdAt: Date(),
            updatedAt: nil,
            parentPath: self.userDocument.reference.path,
            climbedDate: Date(),
            type: "flash"
        )
        let expectPath = [
            FS.Collection.Users.name,
            self.userDocument.id,
            FS.Collection.ClimbRecord.name,
            climbRecordDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            climbRecordDocument.reference.path
        )
    }
}
