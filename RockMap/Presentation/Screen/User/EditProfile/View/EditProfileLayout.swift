import UIKit

extension EditProfileViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =
            UICollectionViewCompositionalLayout { [weak self] sectionNumber, env -> NSCollectionLayoutSection in

                guard let self = self else {
                    return UICollectionViewCompositionalLayout.zeroSizesLayout
                }

                let section: NSCollectionLayoutSection
                let sectionType = SectionLayoutKind.allCases[sectionNumber]

                switch sectionType {
                case .name:
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

                case .introduction:
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

                case .socialLink:
                    var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
                    configuration.showsSeparators = false
                    section = NSCollectionLayoutSection.list(
                        using: configuration,
                        layoutEnvironment: env
                    )
                    section.interGroupSpacing = 16
                    section.contentInsets.bottom = 12

                case .icon:
                    let item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .estimated(88)
                        )
                    )
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: item.layoutSize,
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
                }

                if !sectionType.headerIdentifer.isEmpty {
                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(52)
                        ),
                        elementKind: sectionType.headerIdentifer,
                        alignment: .top
                    )
                    section.boundarySupplementaryItems = [sectionHeader]
                }

                let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(
                    elementKind: SectionBackgroundDecorationView.className
                )
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
