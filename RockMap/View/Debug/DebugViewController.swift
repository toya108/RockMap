//
//  DebugViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/15.
//

import UIKit

class DebugViewController: UIViewController {
    
    private lazy var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
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
            AuthManager.logout { result in
                switch result {
                case .success:
                    guard
                        let vc = UIStoryboard(name: LoginViewController.className, bundle: nil).instantiateInitialViewController()
                    else {
                        return
                    }
                    
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController = vc

                case .failure(let error):
                    showOKAlert(title: "エラー", message: "ログアウトに失敗しました。\(error.localizedDescription)")
                }
            }
        }
        
    }
    
    
}
