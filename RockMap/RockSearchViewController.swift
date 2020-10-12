//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import UIKit

final class RockSearchViewController: UIViewController {

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "岩の名前で探す"
        bar.tintColor = UIColor.gray
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    
}
