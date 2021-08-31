//
//  RockAnnotationsTableViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/27.
//

import UIKit

protocol RockAnnotationTableViewDelegate: AnyObject {
    func didSelectRockAnnotaitonCell(rock: Entity.Rock)
}

class RockAnnotationListViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, Entity.Rock>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, Entity.Rock>!

    private var rocks: [Entity.Rock]!

    weak var delegate: RockAnnotationTableViewDelegate?

    static func createInstance(rocks: [Entity.Rock]) -> Self {
        let vc = Self()
        vc.rocks = rocks
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        configureCollectionView(topInset: 16)
        setupSections()
    }

    private func setupSections() {
        snapShot.appendSections([.main])
        snapShot.appendItems(rocks, toSection: .main)
        datasource.apply(snapShot)
    }
}

extension RockAnnotationListViewController {
    enum SectionKind: Hashable {
        case main
    }
}

extension RockAnnotationListViewController {
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, Entity.Rock> {

        let datasource = UICollectionViewDiffableDataSource<SectionKind, Entity.Rock>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, rock in

            guard let self = self else { return UICollectionViewCell() }

            let registration = UICollectionView.CellRegistration<
                ListCollectionViewCell,
                Entity.Rock
            >(
                cellNib: .init(
                    nibName: ListCollectionViewCell.className,
                    bundle: nil
                )
            ) { cell, _, _ in
                cell.configure(
                    imageUrl: rock.headerUrl,
                    iconImage: UIImage.AssetsImages.rockFill,
                    title: rock.name,
                    first: "登録日: " + rock.createdAt.string(dateStyle: .medium),
                    second: "住所: " + rock.address,
                    third: rock.desc
                )
            }

            return self.collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: rock
            )
        }
        return datasource
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, env -> NSCollectionLayoutSection in
            return NSCollectionLayoutSection.list(
                using: .init(appearance: .insetGrouped),
                layoutEnvironment: env
            )
        }

        return layout
    }
}

extension RockAnnotationListViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let selectedRock = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }

        delegate?.didSelectRockAnnotaitonCell(rock: selectedRock)
    }

}
