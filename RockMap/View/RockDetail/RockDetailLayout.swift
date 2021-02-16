//
//  RockDetailLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import UIKit

extension RockDetailViewController {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        return .init { sectionNumber, env -> NSCollectionLayoutSection in
            
            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            
            switch sectionType {
            case .headerImages:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let height = UIScreen.main.bounds.width * 9/16
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    ),
                    subitems: [item]
                )
                group.interItemSpacing = .fixed(2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                return section
                
            case .registeredUser:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(48)
                    ),
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            case .desc:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(56)
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
                        heightDimension: .estimated(44)
                    ),
                    elementKind: SectionLayoutKind.desc.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                
                return section
                
            case .map:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(64)
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
                        heightDimension: .estimated(44)
                    ),
                    elementKind: SectionLayoutKind.map.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            case .cources:
                
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup
                
                let snapItems = self.snapShot.itemIdentifiers(inSection: .cources)
                
                switch snapItems.first {
                case .noCource:
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(300)
                        )
                    )
                    
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    
                case .cources:
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(300)
                        )
                    )
                    
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                
                default:
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        ),
                        subitems: [item]
                    )
                }
                
                let section = NSCollectionLayoutSection(group: group)
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    ),
                    elementKind: SectionLayoutKind.map.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
                return section
                
            }
        }
    }

}
