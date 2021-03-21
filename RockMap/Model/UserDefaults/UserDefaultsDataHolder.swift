//
//  UserDefaultsDataHolder.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/20.
//

import Foundation

final class UserDefaultsDataHolder {
    
    private enum Key: String {
        case bookMarkedCourseIDs
    }
    
    static let shared: UserDefaultsDataHolder = UserDefaultsDataHolder()
    
    private init() {}
    
    @UserDefaultsStorage(.bookMarkedCourseIDs, defaultValue: [])
    var bookMarkedCourseIDs: [String]
}
