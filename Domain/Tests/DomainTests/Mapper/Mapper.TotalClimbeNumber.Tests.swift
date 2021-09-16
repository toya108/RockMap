@testable import Domain
import DataLayer
import XCTest

final class TotalClimbNumberMapperTests: XCTestCase {

    private let mapper = Domain.Mapper.TotalClimbedNumber()

    private let id = UUID().uuidString
    private let createdAt = Date(timeIntervalSinceNow: 2.0)
    private let updatedAt = Date(timeIntervalSinceNow: 1.0)

    func testMapper() {

        let document = FS.Document.TotalClimbedNumber(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            parentPath: "users/userId/courses/courseId",
            flash: 3,
            redPoint: 4
        )

        let entity = mapper.map(from: document)

        XCTAssertEqual(entity.flash, 3)
        XCTAssertEqual(entity.redPoint, 4)
    }

}
