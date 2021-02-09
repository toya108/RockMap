//
//  Cource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import Foundation

extension FIDocument {
    struct Cource: FIDocumentProtocol {
        typealias Collection = FINameSpace.Cource
        
        var id: String = ""
        var name: String = ""
        var desc: String = ""
        var grade: Grade
        var climbedUserIdList: [String]
        var isPrivate: Bool
        var registedUserId: String
        var registeredDate: Date
        
        enum Grade: Int, CaseIterable, Codable {
            case d5, d4, d3, d2, d1, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10
        }
    }
}
