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
            
            sectionType.headerIdentifer
            
            let section: NSCollectionLayoutSection
            
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
                
                section = .init(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
                
            case .courceName:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                
            case .grade:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(0.15),
                        heightDimension: .fractionalWidth(0.15)
                    ),
                    subitems: [item]
                )
                
                section = .init(group: group)
                section.interGroupSpacing = 4
                section.orthogonalScrollingBehavior = .continuous
                
            case .desc:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(88)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                
            case .images:
                
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup
                
                if self.snapShot.numberOfItems(inSection: .images) == 1 {
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(44)
                        )
                    )
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    
                } else {
                    item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)
                        )
                    )
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(0.25),
                            heightDimension: .fractionalWidth(0.25)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.interGroupSpacing = 4
                    
                }
                
                section.orthogonalScrollingBehavior = .continuous

            case .confirmation:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                section.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing:  0)
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
                section = .init(group: group)
            }
            
            if !sectionType.headerIdentifer.isEmpty {
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    elementKind: sectionType.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            return section

        }
    }
}
