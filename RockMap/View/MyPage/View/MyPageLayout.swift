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
            }

            if !sectionType.headerIdentifer.isEmpty {
                section.boundarySupplementaryItems = [sectionHeader]
            }

            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.className)
            section.decorationItems = [sectionBackgroundDecoration]
            section.contentInsetsReference = .layoutMargins
            
            return section
        }

        return layout
    }
}
