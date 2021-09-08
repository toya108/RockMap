@testable import RockMap
import XCTest

class ForceUpdateAlertManagerTests: XCTestCase {
    func testIsUpdateRequired() throws {
        let forceUpdateAlertManager = ForceUpdateAlertManager()

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0.0",
                currentVersion: "1.0.0"
            )
        )

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0",
                currentVersion: "1.0"
            )
        )

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1",
                currentVersion: "1"
            )
        )

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0.0",
                currentVersion: "2.0.0"
            )
        )

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0.0",
                currentVersion: "1.1.0"
            )
        )

        XCTAssertFalse(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0.0",
                currentVersion: "1.0.1"
            )
        )

        XCTAssertTrue(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "2.0.0",
                currentVersion: "1.0.0"
            )
        )

        XCTAssertTrue(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.1.0",
                currentVersion: "1.0.0"
            )
        )

        XCTAssertTrue(
            forceUpdateAlertManager.isUpdateRequired(
                requiredVersion: "1.0.1",
                currentVersion: "1.0.0"
            )
        )
    }
}
