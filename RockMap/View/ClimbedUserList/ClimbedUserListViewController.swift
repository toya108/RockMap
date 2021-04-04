//
//  ClimbedUserListViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit
import Combine

class ClimbedUserListViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel: ClimbedUserListViewModel!
    private var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ClimbedUserListViewModel.ClimbedCellData>()
    private var datasource: UITableViewDiffableDataSource<SectionKind, ClimbedUserListViewModel.ClimbedCellData>!
    private var bindings = Set<AnyCancellable>()

    enum SectionKind: Hashable {
        case main
    }

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
        snapShot.appendSections([.main])
        datasource.apply(snapShot)
    }

    private func bindViewToViewModel() {
        viewModel.$climbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.appendItems(cellData, toSection: .main)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
}

extension ClimbedUserListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
