//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import Combine
import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestoreSwift

final class RockSearchViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let viewModel = RockSearchViewModel()
    private var bindings = Set<AnyCancellable>()

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "岩の名前で探す"
        bar.searchTextField.backgroundColor = .white
        return bar
    }()
    
    private lazy var trackingButton: MKUserTrackingButton = {
        return .init(mapView: mapView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        updateLocation(LocationManager.shared.location)
        viewModel.fetchRockList()
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
        
        func setupTrackingButton() {
            trackingButton.tintColor = UIColor.Pallete.primaryGreen
            trackingButton.backgroundColor = .white
            trackingButton.layer.cornerRadius = 4
            trackingButton.layer.shadowRadius = Resources.Const.UI.Shadow.radius
            trackingButton.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
            trackingButton.layer.shadowColor = Resources.Const.UI.Shadow.color
            trackingButton.layer.shadowOffset = .init(width: 4, height: 4)
            
            trackingButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(trackingButton)
            NSLayoutConstraint.activate([
                trackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                trackingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
                trackingButton.heightAnchor.constraint(equalToConstant: 44),
                trackingButton.widthAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        setupSearchBar()
        makeNavigationBarTransparent()
        setupTrackingButton()
    }
    
    private func setupMapView() {
        mapView.delegate = self
    }
    
    private func setupBindings() {
        viewModel.$rockDocuments
            .dropFirst()
            .sink { [weak self] documents in
                
                guard let self = self else { return }
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                documents.forEach {
                    let annotation = RockAnnotation(
                        coordinate: .init(latitude: $0.location.latitude, longitude: $0.location.longitude),
                        rock: $0,
                        title: $0.name
                    )
                    self.mapView.addAnnotation(annotation)
                }
            }
            .store(in: &bindings)
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

extension RockSearchViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            return nil
        }
        
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        )
        
        guard
            let markerAnnotationView = annotationView as? MKMarkerAnnotationView
        else {
            return annotationView
        }

        markerAnnotationView.clusteringIdentifier = RockAnnotation.className
        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryGreen
        return markerAnnotationView
    }
    
    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        
        guard
            let rockAnnotation = view.annotation as? RockAnnotation
        else {
            return
        }
        
        let vc = RockDetailViewControllerV2.createInstance(viewModel: .init(rock: rockAnnotation.rock))
        navigationController?.pushViewController(vc, animated: true)
    }
}

class RockAnnotation: NSObject, MKAnnotation {
    
    let rock: FIDocument.Rocks
    let coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(
        coordinate: CLLocationCoordinate2D,
        rock: FIDocument.Rocks,
        title: String
    ) {
        self.rock = rock
        self.coordinate = coordinate
        self.title = title
    }
}
