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
    var viewModel: CourseListViewModel!
    var router: CourselistRouter!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseListViewModel
    ) -> CourseListViewController {
        let instance = CourseListViewController()
        instance.viewModel = viewModel
        instance.router = .init(viewModel: viewModel)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupNavigationBar()
        setupEmptyView()
        configureCollectionView(topInset: 16)
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
        if viewModel.isMine {
            snapShot.appendItems([.annotationHeader], toSection: .annotationHeader)
        }
        datasource.apply(snapShot)
    }

    private func setupViewModelOutput() {
        viewModel.output.$courses
            .removeDuplicates()
            .drop(while: { $0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: coursesSink)
            .store(in: &bindings)

        viewModel.output.$isEmpty
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: isEmptySink)
            .store(in: &bindings)

        viewModel.output.$deleteState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: deleteStateSink)
            .store(in: &bindings)
    }
}

extension CourseListViewController {

    private func coursesSink(_ courses: [Entity.Course]) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .main))
        snapShot.appendItems(courses.map { ItemKind.course($0) }, toSection: .main)
        datasource.apply(snapShot)
    }

    private func isEmptySink(_ isEmpty: Bool) {
        collectionView.isHidden = isEmpty
    }

    private func deleteStateSink(_ state: LoadingState<Void>) {
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

        router.route(to: .courseDetail(course), from: self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        guard viewModel.isMine else { return nil }

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
                    self.makeEditAction(course: course),
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

    private func makeEditAction(course: Entity.Course) -> UIAction {

        return .init(
            title: "編集",
            image: UIImage.SystemImages.squareAndPencil
        ) { [weak self] _ in

            guard let self = self else { return }

            self.router.route(to: .courseRegister(course), from: self)
        }
    }

    private func makeDeleteAction(
        course: Entity.Course
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

                self.viewModel.input.deleteCourseSubject.send(course)
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

extension CourseListViewController: CourseRegisterDetectableViewControllerProtocol {

    func didCourseRegisterFinished() {
        viewModel.fetchCourseList()
    }

}
