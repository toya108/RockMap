//
//  RockAnnotationsTableViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/27.
//

import UIKit

class RockAnnotationsTableViewController: UIViewController {

    private var rocks: [FIDocument.Rock]!

    enum SectionKind: Hashable {
        case main
    }

    let tableView = UITableView()
    private var snapShot = NSDiffableDataSourceSnapshot<SectionKind, FIDocument.Rock>()
    private var datasource: UITableViewDiffableDataSource<SectionKind, FIDocument.Rock>!

    static func createInstance(rocks: [FIDocument.Rock]) -> Self {
        let vc = Self()
        vc.rocks = rocks
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        datasource = configureDatasource()
        setupSections()
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        tableView.register(
            .init(
                nibName: RockTableViewCell.className,
                bundle: nil
            ),
            forCellReuseIdentifier: RockTableViewCell.className
        )
    }

    private func configureDatasource() -> UITableViewDiffableDataSource<SectionKind, FIDocument.Rock> {
        return .init(tableView: tableView) { [weak self] tableView, index, rock in

            guard let self = self else { return UITableViewCell() }

            guard let rockCell = self.tableView.dequeueReusableCell(withIdentifier: RockTableViewCell.className, for: index) as? RockTableViewCell else { return UITableViewCell() }

            return rockCell
            
        }
    }

    private func setupSections() {
        snapShot.appendSections([.main])
        snapShot.appendItems(rocks, toSection: .main)
        datasource.apply(snapShot)
    }
}
