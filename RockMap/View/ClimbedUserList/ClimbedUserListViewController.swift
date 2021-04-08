//
//  ClimbedUserListViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit
import Combine

class ClimbedUserListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel: ClimbedUserListViewModel!
    private var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ClimbedUserListViewModel.ClimbedCellData>()
    private var datasource: UITableViewDiffableDataSource<SectionKind, ClimbedUserListViewModel.ClimbedCellData>!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(course: FIDocument.Course) -> Self {
        let instance = Self()
        instance.viewModel = .init(course: course)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigationBar()
        datasource = configureDatasource()
        setupSections()
        bindViewToViewModel()
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        tableView.contentInset = .init(top: -16, left: 0, bottom: 0, right: 0)

        tableView.register(
            .init(
                nibName: ClimbedTableViewCell.className,
                bundle: nil
            ),
            forCellReuseIdentifier: ClimbedTableViewCell.className
        )
    }

    private func setupNavigationBar() {
        navigationItem.title = "完登者一覧"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func configureDatasource() -> UITableViewDiffableDataSource<SectionKind, ClimbedUserListViewModel.ClimbedCellData> {
        return .init(tableView: tableView) { [weak self] tableView, index, cellData in

            guard let self = self else { return UITableViewCell() }

            guard
                let climbedCell = self.tableView.dequeueReusableCell(
                    withIdentifier: ClimbedTableViewCell.className,
                    for: index
                ) as? ClimbedTableViewCell
            else {
                return UITableViewCell()
            }

            climbedCell.configure(
                user: cellData.user,
                climbedDate: cellData.climbed.climbedDate,
                type: cellData.climbed.type
            )
            return climbedCell

        }
    }

    private func setupSections() {
        snapShot.appendSections(SectionKind.allCases)
        datasource.apply(snapShot)
    }

    private func bindViewToViewModel() {
        viewModel.$climbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.appendItems(cellData.filter { $0.isOwned }, toSection: .owned)
                self.snapShot.appendItems(cellData.filter { !$0.isOwned }, toSection: .others)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
}

extension ClimbedUserListViewController {

    enum SectionKind: Hashable, CaseIterable {
        case owned
        case others

        var headerTitle: String {
            switch self {
                case .owned:
                    return "自分の記録"

                case .others:
                    return "自分以外の記録"
            }
        }
    }

}

extension ClimbedUserListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { _ in
            let edit = UIAction(title: "編集", image: UIImage.SystemImages.squareAndPencil) { [weak self] _ in

                guard let self = self else { return }

            }
            let delete = UIAction(title: "削除", image: UIImage.SystemImages.trash, attributes: .destructive) { [weak self] _ in

                guard let self = self else { return }

                self.showAlert(
                    title: "記録を削除します。",
                    message: "削除した記録は復元できません。\n削除してもよろしいですか？",
                    actions: [
                        .init(title: "削除", style: .destructive) { [weak self] _ in

                            guard let self = self else { return }

                            guard
                                let cellData = self.datasource.itemIdentifier(for: indexPath)
                            else {
                                return
                            }

                            self.showIndicatorView()

                            self.viewModel.deleteClimbed(climbed: cellData.climbed) { result in

                                guard case .success(_) = result else { return }
                                
                                self.snapShot.deleteItems([cellData])
                                self.datasource.apply(self.snapShot)
                                self.hideIndicatorView()

                            }

                        },
                        .init(title: "キャンセル", style: .cancel)
                    ],
                    style: .actionSheet
                )
            }
            return UIMenu(title: "", image: nil, identifier: nil, children: [edit, delete])
        }

        return .init(identifier: nil, previewProvider: nil, actionProvider: actionProvider)

    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = SectionKind.allCases[section].headerTitle
        return header
    }

}

