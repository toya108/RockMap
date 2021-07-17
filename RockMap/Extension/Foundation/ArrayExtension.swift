//
//  ArrayExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/26.
//

import Foundation

extension Array where Element: AnyObject {

    func any(at position: Int) -> Element? {
        
        if position >= count {
            return nil
        }
        
        if position < 0 {
            return nil
        }
        
        return self[position]
    }

}

extension Array where Element: Any {
    func any(at position: Int) -> Element? {
        if position < self.startIndex || position >= self.endIndex {
            return nil
        }
        return self[position]
    }
}
