import UIKit

extension CourseConfirmViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =
            UICollectionViewCompositionalLayout { [weak self] sectionNumber, _ -> NSCollectionLayoutSection in

                guard let self = self else {
                    return UICollectionViewCompositionalLayout.zeroSizesLayout
                }

                let section: NSCollectionLayoutSection
                let sectionType: SectionLayoutKind

                if case .edit = self.viewModel.registerType {
                    sectionType = SectionLayoutKind.allCases.filter { $0 != .rock }[sectionNumber]
                } else {
                    sectionType = SectionLayoutKind.allCases[sectionNumber]
                }

                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(52)
                    ),
                    elementKind: sectionType.headerIdentifer,
                    alignment: .top
                )
                switch sectionType {
                case .rock:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    let collectionViewWidth = self.collectionView.bounds
                        .width -
                        (
                            self.collectionView.layoutMargins.left + self.collectionView
                                .layoutMargins
                                .right
                        )
                    let height = collectionViewWidth * 9 / 16
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(height)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)

                case .courseName, .desc, .grade, .shape:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(32)
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

                case .header:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    let collectionViewWidth = self.collectionView.bounds
                        .width -
                        (
                            self.collectionView.layoutMargins.left + self.collectionView
                                .layoutMargins
                                .right
                        )
                    let height = collectionViewWidth * 9 / 16
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(height)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)

                case .images:

                    if self.viewModel.images.isEmpty {
                        return UICollectionViewCompositionalLayout.zeroSizesLayout
                    }

                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(0.4),
                            heightDimension: .fractionalWidth(0.4)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.interGroupSpacing = 4
                    section.orthogonalScrollingBehavior = .continuous

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
                }

                if !sectionType.headerIdentifer.isEmpty {
                    section.boundarySupplementaryItems = [sectionHeader]
                }

                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem
                    .background(elementKind: SectionBackgroundDecorationView.className)
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
