//
//  CourseListViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/23.
//

import UIKit
import Combine

class CourseListViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    let emptyLabel = UILabel()
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!
    var viewModel: CourseListViewModelProtocol!

    private var bindings = Set<AnyCancellable>()

    enum SectionKind: CaseIterable, Hashable {
        case main
    }

    enum ItemKind: Hashable {
        case course(FIDocument.Course)
    }

    static func createInstance(viewModel: CourseListViewModelProtocol) -> CourseListViewController {
        let instance = CourseListViewController()
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        snapShot.appendSections(SectionKind.allCases)
        setupViewModelOutput()
    }

    private func setupEmptyView() {
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        emptyLabel.text = "課題が見つかりませんでした。"
        NSLayoutConstraint.activate([
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupViewModelOutput() {
        viewModel.output.$courses
            .removeDuplicates()
            .drop(while: { $0.isEmpty })
            .receive(on: RunLoop.main)
            .sink { [weak self] couses in

                guard let self = self else { return }

                self.snapShot.appendItems(couses.map { ItemKind.course($0) }, toSection: .main)
            }
            .store(in: &bindings)

        viewModel.output.$isEmpty
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isEmpty in

                guard let self = self else { return }

                self.collectionView.isHidden = !isEmpty
            }
            .store(in: &bindings)
    }
}

extension CourseListViewController {

    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionKind, ItemKind> {
        let datasource = UICollectionViewDiffableDataSource<SectionKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return UICollectionViewCell() }

            switch item {
                case let .course(course):
                    
                    let registration = UICollectionView.CellRegistration<
                        CourseListCollectionViewCell,
                        FIDocument.Course
                    > { cell, _, _ in
                        cell.configure(course: course)
                    }
                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: course
                    )
            }

        }
        return datasource
    }

    func createLayout() -> UICollectionViewCompositionalLayout {

        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in

            let section: NSCollectionLayoutSection

            let sectionType = SectionKind.allCases[sectionNumber]

            switch sectionType {
                case .main:
                    section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: env)
            }

            return section

        }

        return layout
    }

}
