//
//  CourceRegisterLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

extension CourceRegisterViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return .init { sectionNumber, env -> NSCollectionLayoutSection in
            
            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            
            switch sectionType {
            case .rock:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(414)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)

                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    elementKind: SectionLayoutKind.rock.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
                return section
                
            default:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
    }

}
