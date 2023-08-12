@testable import RockMap
import DataLayer
import FirebaseFirestore
import XCTest

final class ClimbRecordMapperTests: XCTestCase {

    private let mapper = Domain.Mapper.ClimbRecord()

    private let createdAt = Date(timeIntervalSinceNow: 2.0)
    private let updatedAt = Date(timeIntervalSinceNow: 1.0)
    private let climbedDate = Date(timeIntervalSinceNow: 3.0)

    func testClimbRecordMapper() {

        let document = FS.Document.ClimbRecord(
            id: "123456789",
            registeredUserId: "userID",
            parentCourseId: "parentCourseId",
            parentCourseReference: Firestore.firestore().document("users/userID/courses/courseID"),
            totalNumberReference: Firestore.firestore().document(
                "users/userID/courses/courseID/totalNumbers/totalNumbersID"
            ),
            createdAt: createdAt,
            updatedAt: updatedAt,
            climbedDate: climbedDate,
            type: "flash"
        )

        let entity = mapper.map(from: document)

        XCTAssertEqual(entity.id, "123456789")
        XCTAssertEqual(entity.registeredUserId, "userID")
        XCTAssertEqual(entity.parentCourseId, "parentCourseId")
        XCTAssertEqual(entity.parentCourseReference, "users/userID/courses/courseID")
        XCTAssertEqual(entity.createdAt, createdAt)
        XCTAssertEqual(entity.updatedAt, updatedAt)
        XCTAssertEqual(entity.climbedDate, climbedDate)
        XCTAssertEqual(entity.type, .flash)
    }

    func testMapperWithClimbType() {

        var document = FS.Document.ClimbRecord(
            id: "123456789",
            registeredUserId: "userID",
            parentCourseId: "parentCourseId",
            parentCourseReference: Firestore.firestore().document("users/userID/courses/courseID"),
            totalNumberReference: Firestore.firestore().document(
                "users/userID/courses/courseID/totalNumbers/totalNumbersID"
            ),
            createdAt: createdAt,
            updatedAt: updatedAt,
            climbedDate: climbedDate,
            type: "flash"
        )

        XCTAssertEqual(mapper.map(from: document).type, .flash)

        document.type = "redPoint"

        XCTAssertEqual(mapper.map(from: document).type, .redPoint)
    }

}
