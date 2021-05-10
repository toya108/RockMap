//
//  UserLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/19.
//

import UIKit

extension UserViewController {

    func createLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

            let section: NSCollectionLayoutSection

            let sectionType = SectionKind.allCases[sectionNumber]
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
                    section.contentInsets.bottom = 16
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

                case .introduction:
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

                case .recentClimbedCourses:
                    let item: NSCollectionLayoutItem
                    let group: NSCollectionLayoutGroup

                    if
                        self.snapShot.itemIdentifiers(inSection: .recentClimbedCourses).count == 1,
                        case .noCourse = self.snapShot.itemIdentifiers(inSection: .recentClimbedCourses).first
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

                    section.contentInsets.bottom = 16

                case .registered:
                    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                    section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: env)
                    section.boundarySupplementaryItems = [sectionHeader]
                    section.contentInsets.top = 0
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

        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: SectionBackgroundDecorationView.className
        )
        return layout
    }
}
