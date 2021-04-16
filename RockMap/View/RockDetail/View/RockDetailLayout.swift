//
//  RockDetailLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/08.
//

import UIKit

extension RockDetailViewController {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, _ -> NSCollectionLayoutSection in
            
            let section: NSCollectionLayoutSection
            
            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(52)
                ),
                elementKind: sectionType.headerIdentifer,
                alignment: .top
            )
            switch sectionType {
            case .header:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                let collectionViewWidth = self.collectionView.bounds.width - (self.collectionView.layoutMargins.left + self.collectionView.layoutMargins.right)
                let height = collectionViewWidth * 3/4
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                return section

            case .title:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(40)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: item.layoutSize,
                    subitems: [item]
                )
                section = .init(group: group)
                section.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)

            case .registeredUser:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(40)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: item.layoutSize,
                    subitems: [item]
                )
                section = .init(group: group)
                section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)

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
                section = .init(group: group)
                
            case .info:
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
                section = .init(group: group)
                
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
                section = .init(group: group)
                
            case .courses:
                
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup
                
                if
                    self.snapShot.itemIdentifiers(inSection: .courses).count == 1,
                    case .nocourse = self.snapShot.itemIdentifiers(inSection: .courses).first
                {
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(160)
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
                            heightDimension: .estimated(300)
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
                    section.interGroupSpacing = 8
                    section.orthogonalScrollingBehavior = .groupPaging
                }

            case .images:
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup

                if
                    self.snapShot.itemIdentifiers(inSection: .images).count == 1,
                    self.snapShot.itemIdentifiers(inSection: .images).first == .some(.noImage)
                {
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    let collectionViewWidth = self.collectionView.bounds.width - (self.collectionView.layoutMargins.left + self.collectionView.layoutMargins.right)
                    let height = collectionViewWidth * 9/16
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(height)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)

                } else {
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1/3),
                            heightDimension: .fractionalWidth(1/3)
                        )
                    )
                    item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.boundarySupplementaryItems = [sectionHeader]
                }
            }
            
            if !sectionType.headerIdentifer.isEmpty {
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.className)
            section.decorationItems = [sectionBackgroundDecoration]
            section.contentInsetsReference = .layoutMargins
            
            return section
        }
        
        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: SectionBackgroundDecorationView.className
        )
        return layout
    }

}
