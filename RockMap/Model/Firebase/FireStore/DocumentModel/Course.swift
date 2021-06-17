//
//  Course.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import Foundation
import UIKit

extension FIDocument {

    struct Course: FIDocumentProtocol, UserRegisterableDocumentProtocol {
        
        typealias Collection = FINameSpace.Course
        
        var id: String = UUID().uuidString
        var parentPath: String
        var createdAt: Date = Date()
        var updatedAt: Date?
        var name: String
        var desc: String
        var grade: Grade
        var shape: Set<Shape>
        var parentRockName: String
        var parentRockId: String
        var registeredUserId: String
        var headerUrl: URL?
        var imageUrls: [URL] = []
    }

}

extension FIDocument.Course {

    enum Grade: String, CaseIterable, Codable {
        case d5, d4, d3, d2, d1, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10

        var name: String {
            switch self {
                case .d5:
                    return "5段"
                    
                case .d4:
                    return "4段"
                    
                case .d3:
                    return "3段"
                    
                case .d2:
                    return "2段"
                    
                case .d1:
                    return "初段"
                    
                case .q1:
                    return "1級"
                    
                case .q2:
                    return "2級"
                    
                case .q3:
                    return "3級"
                    
                case .q4:
                    return "4級"
                    
                case .q5:
                    return "5級"
                    
                case .q6:
                    return "6級"
                    
                case .q7:
                    return "7級"
                    
                case .q8:
                    return "8級"
                    
                case .q9:
                    return "9級"
                    
                case .q10:
                    return "10級"
                    
            }
        }
    }

    enum Shape: String, CaseIterable, Codable {
        case roof, slab, face, overhang, kante, lip

        var name: String {
            switch self {
                case .roof:
                    return "ルーフ"
                    
                case .slab:
                    return "スラブ"
                    
                case .face:
                    return "垂壁"
                    
                case .overhang:
                    return "オーバーハング"
                    
                case .kante:
                    return "カンテ"
                    
                case .lip:
                    return "リップ"
                    
            }
        }

    }
}
