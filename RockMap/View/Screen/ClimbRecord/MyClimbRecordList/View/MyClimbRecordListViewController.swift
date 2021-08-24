//
//  MyClimbedViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/27.
//

import UIKit
import Combine

class MyClimbedListViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    let emptyLabel = UILabel()
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!
    var viewModel: MyClimbedListViewModel!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: MyClimbedListViewModel
    ) -> MyClimbedListViewController {
        let instance = MyClimbedListViewController()
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupNavigationBar()
        setupEmptyView()
        configureCollectionView()
        setupSections()
        setupViewModelOutput()
    }

    private func setupSubViews() {
        view.backgroundColor = .systemGroupedBackground
    }

    private func setupNavigationBar() {
        navigationItem.title = "登った課題一覧"
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

    private func setupSections() {
        snapShot.appendSections(SectionKind.allCases)
        datasource.apply(snapShot)
    }

    private func setupViewModelOutput() {
        viewModel.output.$climbedCourses
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] climbedCourses in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .main))
                self.snapShot.appendItems(
                    climbedCourses.map { ItemKind.course($0) },
                    toSection: .main
                )
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output.$isEmpty
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in

                guard let self = self else { return }

                self.collectionView.isHidden = isEmpty
            }
            .store(in: &bindings)
    }
}

extension MyClimbedListViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let item = datasource.itemIdentifier(for: indexPath),
            case let .course(climbedCourse) = item
        else {
            return
        }

        // temporary
        let courseViewModel = CourseDetailViewModel(
            course: .init(
                id: climbedCourse.course.id,
                parentPath: climbedCourse.course.parentPath,
                createdAt: climbedCourse.course.createdAt,
                updatedAt: climbedCourse.course.updatedAt,
                name: climbedCourse.course.name,
                desc: climbedCourse.course.desc,
                grade: .init(rawValue: climbedCourse.course.grade.rawValue) ?? .q10,
                shape: Set(climbedCourse.course.shape.compactMap { .init(rawValue: $0.rawValue) }),
                parentRockName: climbedCourse.course.parentRockName,
                parentRockId: climbedCourse.course.parentRockId,
                registeredUserId: climbedCourse.course.registeredUserId,
                headerUrl: climbedCourse.course.headerUrl,
                imageUrls: climbedCourse.course.imageUrls
            )
        )
        let courseDetailViewController = CourseDetailViewController.createInstance(viewModel: courseViewModel)
        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }
}
