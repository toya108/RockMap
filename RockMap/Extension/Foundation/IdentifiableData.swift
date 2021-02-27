//
//  IdentifiableData.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/20.
//

import Foundation

struct IdentifiableData: Identifiable, Hashable {
    let id = UUID()
    let data: Data
}
