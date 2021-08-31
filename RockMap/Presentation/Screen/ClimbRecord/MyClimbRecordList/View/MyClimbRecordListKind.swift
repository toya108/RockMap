//
//  MyClimbedKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/27.
//

import Foundation

extension MyClimbedListViewController {

    enum SectionKind: CaseIterable, Hashable {
        case main
    }

    enum ItemKind: Hashable {
        case course(MyClimbedListViewModel.ClimbedCourse)
    }

}
