//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import UIKit
import FirebaseFirestore
import MapKit

final class RockSearchViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "岩の名前で探す"
        bar.tintColor = UIColor.gray
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        
        let coordinate = CLLocationCoordinate2DMake(35.801128, 139.175756)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "デッドエンド岩"
        mapView.addAnnotation(pin)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    
}
