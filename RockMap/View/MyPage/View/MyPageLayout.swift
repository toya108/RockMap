//
//  MyPageLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import UIKit

extension MyPageViewController {

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

                case .user:
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

                case .socialLink:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .estimated(28),
                            heightDimension: .estimated(28)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    group.interItemSpacing = .fixed(8)
                    section = .init(group: group)
                    section.contentInsets = .init(top: 16, leading: 0, bottom: 16, trailing: 0)
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
