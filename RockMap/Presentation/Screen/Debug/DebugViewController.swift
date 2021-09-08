#if DEBUG

import Auth
import Combine
import UIKit

class DebugViewController: UIViewController {
    private lazy var tableView = UITableView()
    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
    }

    private func setupTableView() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.tableView)
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

private enum DebugCellType: Int, CaseIterable {
    case logout

    var title: String {
        switch self {
        case .logout:
            return "Logout"
        }
    }
}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DebugCellType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellType = DebugCellType.allCases[indexPath.row]

        switch cellType {
        case .logout:
            cell.textLabel?.text = cellType.title
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = DebugCellType.allCases[indexPath.row]

        switch cellType {
        case .logout:
            AuthManager.shared.logout()
                .catch { _ -> Just<Void> in
                    .init(())
                }
                .sink {
                    guard
                        let vc = UIStoryboard(name: LoginViewController.className, bundle: nil)
                            .instantiateInitialViewController()
                    else {
                        return
                    }

                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                        .rootViewController = vc
                }
                .store(in: &self.bindings)
        }
    }
}

#endif
