@testable import DataLayer
import FirebaseFirestore
import XCTest
import Firebase
import Foundation

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en-US")
    f.dateFormat = "yyyyMMddHHmmssSSS"
    return f
}()

enum FirebaseTestHelper {
    static func setupFirebaseApp() {
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(googleAppID: "1:123:ios:123abc", gcmSenderID: "sender_id")
            options.projectID = "test-" + dateFormatter.string(from: Date())
            options.storageBucket = "project-id-123.storage.firebase.com"
            FirebaseApp.configure(options: options)
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            print("FirebaseApp has been configured")
        }
    }

    static func deleteFirebaseApp() {
        guard let app = FirebaseApp.app() else {
            return
        }
        app.delete { _ in print("FirebaseApp has been deleted") }
    }
}

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
        deleted: false,
        tokenMap: [:]
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
            name: "aaa",
            address: "北海道",
            prefecture: "北海道",
            location: .init(latitude: 0.0, longitude: 0.0),
            seasons: [],
            lithology: "chert",
            area: "御岳",
            desc: "aaa",
            registeredUserId: self.userDocument.id,
            headerUrl: nil,
            imageUrls: [],
            tokenMap: ["aa": true]
        )

        let expectPath = [
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
            imageUrls: [],
            tokenMap: ["aa": true]
        )
        let expectPath = [
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
            climbedDate: Date(),
            type: "flash"
        )
        let expectPath = [
            FS.Collection.ClimbRecord.name,
            climbRecordDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            climbRecordDocument.reference.path
        )
    }
}
