import UIKit

extension MyClimbedListViewController {
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout =
            UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

                let section: NSCollectionLayoutSection

                let sectionType = SectionKind.allCases[sectionNumber]

                switch sectionType {
                case .main:
                    section = .list(
                        using: .init(appearance: .insetGrouped),
                        layoutEnvironment: env
                    )
                }

                return section
            }

        return layout
    }
}
