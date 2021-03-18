//
//  courseConfirmLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//


import UIKit

extension CourseConfirmViewController {
    
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
                sectionHeader.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
                
            case .courseName, .desc, .grade, .shape:
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
                
            case .images:
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
                section = .init(group: group)
                sectionHeader.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.boundarySupplementaryItems = [sectionHeader]
                section.orthogonalScrollingBehavior = .paging
                return section

            case .register:
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
                section.contentInsets.top = 16
                
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
