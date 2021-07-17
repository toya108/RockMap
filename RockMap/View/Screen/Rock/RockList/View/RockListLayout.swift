//
//  RockListLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import UIKit

extension RockListViewController {

    func createLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

            let section: NSCollectionLayoutSection

            let sectionType = SectionKind.allCases[sectionNumber]

            switch sectionType {
                case .annotationHeader:
                    section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: env)
                    section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

                case .main:
                    section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: env)
            }

            return section

        }

        return layout
    }

}
