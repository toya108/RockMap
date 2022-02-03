import Combine
import UIKit

class ClimbedUserListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel: ClimbedUserListViewModel!
    private var snapShot = NSDiffableDataSourceSnapshot<
        SectionKind,
        ClimbedUserListViewModel.ClimbedCellData
    >()
    private var datasource: UITableViewDiffableDataSource<
        SectionKind,
        ClimbedUserListViewModel.ClimbedCellData
    >!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(course: Entity.Course) -> Self {
        let instance = Self()
        instance.viewModel = .init(course: course)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.setupNavigationBar()
        self.datasource = self.configureDatasource()
        self.setupSections()
        self.bindViewToViewModel()
    }

    private func setupTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        self.tableView.register(
            .init(
                nibName: ClimbRecordTableViewCell.className,
                bundle: nil
            ),
            forCellReuseIdentifier: ClimbRecordTableViewCell.className
        )
    }

    private func setupNavigationBar() {
        navigationItem.title = "完登者一覧"
    }

    private func configureDatasource() -> UITableViewDiffableDataSource<
        SectionKind,
        ClimbedUserListViewModel.ClimbedCellData
    > {
        .init(tableView: self.tableView) { [weak self] _, index, cellData in

            guard let self = self else { return UITableViewCell() }

            guard
                let climbedCell = self.tableView.dequeueReusableCell(
                    withIdentifier: ClimbRecordTableViewCell.className,
                    for: index
                ) as? ClimbRecordTableViewCell
            else {
                return UITableViewCell()
            }

            climbedCell.configure(
                user: cellData.user,
                climbedDate: cellData.climbed.climbedDate,
                type: cellData.climbed.type,
                parentVc: self
            )
            return climbedCell
        }
    }

    private func setupSections() {
        self.snapShot.appendSections(SectionKind.allCases)
        self.datasource.apply(self.snapShot)
    }

    private func bindViewToViewModel() {
        self.viewModel.output.$myClimbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .owned))
                self.snapShot.appendItems(cellData, toSection: .owned)

                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.output.$climbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .others))
                self.snapShot.appendItems(cellData, toSection: .others)

                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)
    }

    private func makeEditAction(
        to cellData: ClimbedUserListViewModel.ClimbedCellData
    ) -> UIAction {
        .init(
            title: "編集",
            image: Resources.Images.System.squareAndPencil.uiImage
        ) { [weak self] _ in

            guard let self = self else { return }

            let vm = RegisterClimbRecordViewModel(registerType: .edit(cellData.climbed))
            let vc = RegisterClimbRecordBottomSheetViewController.createInstance(viewModel: vm)
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }

    private func makeDeleteAction(
        to cellData: ClimbedUserListViewModel.ClimbedCellData
    ) -> UIAction {
        .init(
            title: "削除",
            image: Resources.Images.System.trash.uiImage,
            attributes: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }

            let deleteAction = UIAlertAction(
                title: "削除",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                self.showIndicatorView()

                Task {
                    do {
                        try await self.viewModel.deleteClimbRecord(
                            climbRecord: cellData.climbed
                        )
                        self.hideIndicatorView()
                        self.snapShot.deleteItems([cellData])
                        await self.datasource.apply(self.snapShot)
                    } catch {
                        self.hideIndicatorView()
                        self.showOKAlert(
                            title: "削除に失敗しました。",
                            message: error.localizedDescription
                        )
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

            self.showAlert(
                title: "記録を削除します。",
                message: "削除した記録は復元できません。\n削除してもよろしいですか？",
                actions: [
                    deleteAction,
                    cancelAction
                ],
                style: .actionSheet
            )
        }
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
        guard
            let cellData = self.datasource.itemIdentifier(for: indexPath),
            cellData.isOwned
        else {
            return nil
        }

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { [weak self] _ in

            guard let self = self else { return nil }

            return UIMenu(
                title: "",
                children: [
                    self.makeEditAction(to: cellData),
                    self.makeDeleteAction(to: cellData)
                ]
            )
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

extension ClimbedUserListViewController: RegisterClimbRecordDetectableDelegate {
    func finishedRegisterClimbed(
        id: String,
        date: Date,
        type: Entity.ClimbRecord.ClimbedRecordType
    ) {
        self.viewModel.updateClimbedData(
            id: id,
            date: date,
            type: type
        )
    }
}
