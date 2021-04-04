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

        var id: String
        var parentCourseId: String
        var createdAt: Date
        var updatedAt: Date?
        var parentPath: String
        var total: Int
        var flashTotal: Int
        var redPointTotal: Int
    }
}
