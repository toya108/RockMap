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
    @IBOutlet weak var currentLocationButton: UIButton!
    
    private let viewModel = RockSearchViewModel()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "岩の名前で探す"
        bar.searchTextField.backgroundColor = .white
        return bar
    }()
    
    @IBAction func didCurrentLocationButtonTapped(_ sender: UIButton) {
        updateLocation(LocationManager.shared.location)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocation(LocationManager.shared.location)
    }
    
    private func setupLayout() {
        func setupSearchBar() {
            searchBar.delegate = self
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
        }
        
        func makeNavigationBarTransparent() {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        
        func setupCurrentLocationButton() {
            currentLocationButton.layer.cornerRadius = 24
            
            currentLocationButton.layer.shadowRadius = Resources.Const.UI.Shadow.radius
            currentLocationButton.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
            currentLocationButton.layer.shadowColor = Resources.Const.UI.Shadow.color
            currentLocationButton.layer.shadowOffset = .init(width: 4, height: 4)
        }
        
        setupSearchBar()
        makeNavigationBarTransparent()
        setupCurrentLocationButton()
    }
    
    private func updateLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        mapView.setRegion(
            .init(center: location.coordinate, span: span),
            animated: true
        )
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    
}
