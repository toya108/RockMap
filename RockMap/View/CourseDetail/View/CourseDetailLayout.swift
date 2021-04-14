//
//  CourseDetailLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit

extension CourseDetailViewController {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in
            let section: NSCollectionLayoutSection

            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(44)
                ),
                elementKind: sectionType.headerIdentifer,
                alignment: .top
            )
            
            switch sectionType {
                case .headerImage:
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
                    
                case .buttons:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(44)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: item.layoutSize,
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                    
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
                    
                case .climbedNumber:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(64)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: item.layoutSize,
                        subitems: [item]
                    )
                    section = .init(group: group)
                    
                case .info:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(64)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: item.layoutSize,
                        subitems: [item]
                    )
                    section = .init(group: group)

                case .desc:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(64)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: item.layoutSize,
                        subitems: [item]
                    )
                    section = .init(group: group)

                case .images:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1/3),
                            heightDimension: .fractionalWidth(1/3)
                        )
                    )
                    item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.boundarySupplementaryItems = [sectionHeader]
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
