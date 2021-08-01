//
//  TotalClimbedNumber.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import Foundation
import FirebaseFirestoreSwift

extension FIDocument {

    struct TotalClimbedNumber: FIDocumentProtocol {

        typealias Collection = FINameSpace.TotalClimbedNumber

        var id: String
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var flash: Int
        var redPoint: Int
    }
    
}
