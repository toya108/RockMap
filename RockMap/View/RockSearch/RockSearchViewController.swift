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
        bar.tintColor = UIColor.gray
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
//        FireStoreClient.db.collection(RockDocument.collectionName).getDocuments { [weak self] snap, error in
            
//            guard let self = self else { return }
//
//            snap?.documents.filter { $0.exists }.forEach {
//                do {
//                    let rock = try Firestore.Decoder().decode(RockDocument.self, from: $0.data())
//
//                    let coordinate = CLLocationCoordinate2DMake(rock.point.latitude, rock.point.longitude)
//                    let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//                    let region = MKCoordinateRegion(center: coordinate, span: span)
//                    self.mapView.setRegion(region, animated: true)
//
//                    let pin = MKPointAnnotation()
//                    pin.coordinate = coordinate
//                    pin.title = rock.name
//                    self.mapView.addAnnotation(pin)
//                } catch {
//                    fatalError()
//                }
//            }
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.titleView?.frame = searchBar.frame
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    
}
