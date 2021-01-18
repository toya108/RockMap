//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestoreSwift

final class RockSearchViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "岩の名前で探す"
        bar.searchTextField.backgroundColor = .white
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    
}
