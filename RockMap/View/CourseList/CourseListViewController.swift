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
        case annotationHeader
        case main
    }

    enum ItemKind: Hashable {
        case annotationHeader
        case course(FIDocument.Course)
    }

    static func createInstance(
        viewModel: CourseListViewModelProtocol
    ) -> CourseListViewController {
        let instance = CourseListViewController()
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
        navigationItem.title = "登録した課題一覧"
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
        snapShot.appendItems([.annotationHeader], toSection: .annotationHeader)
        datasource.apply(snapShot)
    }

    private func setupViewModelOutput() {
        viewModel.output.$courses
            .removeDuplicates()
            .drop(while: { $0.isEmpty })
            .receive(on: RunLoop.main)
            .sink { [weak self] couses in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .main))
                self.snapShot.appendItems(couses.map { ItemKind.course($0) }, toSection: .main)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output.$isEmpty
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] isEmpty in

                guard let self = self else { return }

                self.collectionView.isHidden = isEmpty
            }
            .store(in: &bindings)

        viewModel.output.$deleteState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in

                guard let self = self else { return }

                switch state {
                    case .loading:
                        self.showIndicatorView()

                    case .finish, .stanby:
                        self.hideIndicatorView()

                    case .failure(let error):
                        self.hideIndicatorView()
                        self.showOKAlert(
                            title: "削除に失敗しました",
                            message: error?.localizedDescription ?? ""
                        )
                }
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
                case .annotationHeader:
                    let registration = UICollectionView.CellRegistration<
                        AnnotationHeaderCollectionViewCell,
                        Dummy
                    > { cell, _, _ in
                        cell.configure(title: "課題を長押しすると編集/削除ができます。")
                    }

                    return self.collectionView.dequeueConfiguredReusableCell(
                        using: registration,
                        for: indexPath,
                        item: Dummy()
                    )
                    
                case let .course(course):
                    let registration = UICollectionView.CellRegistration<
                        CourseListCollectionViewCell,
                        FIDocument.Course
                    >(
                        cellNib: .init(
                            nibName: CourseListCollectionViewCell.className,
                            bundle: nil
                        )
                    ) { cell, _, _ in
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
                case .annotationHeader:
                    section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: env)
                    section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                    
                case .main:
                    section = .list(using: .init(appearance: .insetGrouped), layoutEnvironment: env)
            }

            return section

        }

        return layout
    }

}

extension CourseListViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let item = datasource.itemIdentifier(for: indexPath),
            case let .course(course) = item
        else {
            return
        }

        let vc = CourseDetailViewController.createInstance(viewModel: .init(course: course))
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { [weak self] _ in

            guard let self = self else { return nil }

            guard
                let item = self.datasource.itemIdentifier(for: indexPath),
                case let .course(course) = item
            else {
                return nil
            }

            return UIMenu(
                title: "",
                children: [
                    self.makeEditAction(),
                    self.makeDeleteAction(course: course)
                ]
            )
        }

        return .init(
            identifier: nil,
            previewProvider: nil,
            actionProvider: actionProvider
        )

    }

    private func makeEditAction() -> UIAction {

        return .init(
            title: "編集",
            image: UIImage.SystemImages.squareAndPencil
        ) { [weak self] _ in

            guard let self = self else { return }

        }
    }

    private func makeDeleteAction(
        course: FIDocument.Course
    ) -> UIAction {

        return .init(
            title: "削除",
            image: UIImage.SystemImages.trash,
            attributes: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }

            let deleteAction = UIAlertAction(
                title: "削除",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.input.deleteCourse(course)
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

            self.showAlert(
                title: "課題を削除します。",
                message: "削除した課題は復元できません。\n削除してもよろしいですか？",
                actions: [
                    deleteAction,
                    cancelAction
                ],
                style: .actionSheet
            )
        }
    }
    
}
