//
//  ArrayExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/26.
//

import Foundation

public extension Array where Element: AnyObject {

    func any(at position: Int) -> Element? {
        
        if position >= self.count {
            return nil
        }
        
        if position < 0 {
            return nil
        }
        
        return self[position]
    }

}
