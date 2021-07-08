//
//  DocumentProtocolTests.swift
//  RockMapTests
//
//  Created by TOUYA KAWANO on 2021/06/16.
//

import XCTest
import FirebaseFirestore
@testable import RockMap

class DocumentProtocolTests: XCTestCase {

    private let userDocument = FIDocument.User(id: UUID().uuidString, name: "foo")
    private let dummyDocumentReference = Firestore.firestore().collection("aaa").document()

    func testMakeUserDocument() throws {
        XCTAssertEqual(
            FIDocument.User.colletionName + "/" + userDocument.id,
            userDocument.makeDocumentReference().path
        )
    }

    func testMakeRockDocument() throws {
        let rockDocument = FIDocument.Rock(
            parentPath: userDocument.makeDocumentReference().path,
            name: "aaa",
            address: "北海道",
            prefecture: "北海道",
            location: .init(latitude: 0.0, longitude: 0.0),
            seasons: [],
            lithology: .andesite,
            desc: "aaa",
            registeredUserId: userDocument.id
        )

        let expectPath = [
            FIDocument.User.colletionName,
            userDocument.id,
            FIDocument.Rock.colletionName,
            rockDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            rockDocument.makeDocumentReference().path
        )
    }

    func testMakeCourseDocument() throws {
        let courseDocument = FIDocument.Course(
            parentPath: userDocument.makeDocumentReference().path,
            name: "aaa",
            desc: "aaa",
            grade: .d1,
            shape: [],
            parentRockName: "rock",
            parentRockId: UUID().uuidString,
            registeredUserId: userDocument.id
        )
        let expectPath = [
            FIDocument.User.colletionName,
            userDocument.id,
            FIDocument.Course.colletionName,
            courseDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            courseDocument.makeDocumentReference().path
        )
    }

    func testMakeClimbedDocument() throws {
        let climbedDocument = FIDocument.ClimbRecord(
            registeredUserId: userDocument.id,
            parentCourseId: dummyDocumentReference.documentID,
            parentCourseReference: dummyDocumentReference,
            totalNumberReference: dummyDocumentReference,
            parentPath: userDocument.makeDocumentReference().path,
            climbedDate: Date(),
            type: .flash
        )
        let expectPath = [
            FIDocument.User.colletionName,
            userDocument.id,
            FIDocument.ClimbRecord.colletionName,
            climbedDocument.id
        ].joined(separator: "/")

        XCTAssertEqual(
            expectPath,
            climbedDocument.makeDocumentReference().path
        )
    }

}
