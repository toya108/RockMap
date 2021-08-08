//
//  TotalClimbedNumber.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import Foundation
import FirebaseFirestoreSwift

extension FS.Document {

    struct TotalClimbedNumber: DocumentProtocol {

        var collection: CollectionProtocol.Type { FS.Collection.TotalClimbedNumber.self }

        var id: String
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var flash: Int
        var redPoint: Int
    }
    
}
