//
//  RockListKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import Foundation

extension RockListViewController {

    enum SectionKind: CaseIterable, Hashable {
        case annotationHeader
        case main
    }

    enum ItemKind: Hashable {
        case annotationHeader
        case rock(FIDocument.Rock)
    }

}
