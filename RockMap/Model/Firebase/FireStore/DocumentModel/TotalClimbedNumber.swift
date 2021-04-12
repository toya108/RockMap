//
//  TotalClimbedNumber.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import Foundation

extension FIDocument {
    struct TotalClimbedNumber: FIDocumentProtocol {

        typealias Collection = FINameSpace.TotalClimbedNumber

        var id: String = UUID().uuidString
        var parentCourseReference: DocumentRef
        var createdAt: Date = Date()
        var updatedAt: Date? = nil
        var parentPath: String
        var total: Int = 0
        var flashTotal: Int = 0
        var redPointTotal: Int = 0
    }
}
