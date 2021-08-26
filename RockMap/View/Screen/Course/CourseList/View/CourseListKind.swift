//
//  CourseListKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/05.
//

import Foundation

extension CourseListViewController {

    enum SectionKind: CaseIterable, Hashable {
        case annotationHeader
        case main
    }

    enum ItemKind: Hashable {
        case annotationHeader
        case course(Entity.Course)
    }

}
