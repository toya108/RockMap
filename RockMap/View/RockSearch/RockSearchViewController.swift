//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import Combine
import UIKit
import MapKit

final class RockSearchViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let viewModel = RockSearchViewModel()
    private var bindings = Set<AnyCancellable>()
    @IBOutlet weak var buttonStackView: UIStackView!

    private lazy var trackingButton: MKUserTrackingButton = {
        return .init(mapView: mapView)
    }()

    @IBOutlet weak var selectLocationButton: UIButton!

    @IBAction func selectLocationButtonTapped(_ sender: UIButton) {
        if viewModel.locationSelectState == .standby {
            viewModel.locationSelectState = .selecting
        } else {
            viewModel.locationSelectState = .standby
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
        setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        updateLocation(LocationManager.shared.location)
        viewModel.fetchRockList()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    private func setupLayout() {

        func setupTrackingButton() {
            trackingButton.tintColor = UIColor.Pallete.primaryGreen
            trackingButton.backgroundColor = .white
            trackingButton.layer.cornerRadius = 4
            trackingButton.addShadow()
            
            trackingButton.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.addArrangedSubview(trackingButton)
            NSLayoutConstraint.activate([
                trackingButton.heightAnchor.constraint(equalToConstant: 44),
                trackingButton.widthAnchor.constraint(equalToConstant: 44)
            ])
        }

        func setupSelectLocationButton() {
            selectLocationButton.layer.cornerRadius = 22
            selectLocationButton.addShadow()
        }

        setupTrackingButton()
        setupSelectLocationButton()
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

        viewModel.$locationSelectState
            .removeDuplicates()
            .sink { [weak self] state in

                guard let self = self else { return }

                self.updateSelectButtonLayout(state: state)
                self.updateMapView(state: state)
            }
            .store(in: &bindings)
    }

    private func updateSelectButtonLayout(state: LocationSelectButtonState) {
        UIView.animate(withDuration: 0.2) {
            self.selectLocationButton.backgroundColor = state.backGroundColor
            self.selectLocationButton.tintColor = state.tintColor
            self.selectLocationButton.setImage(state.image, for: .normal)
        }
    }

    private func updateMapView(state: LocationSelectButtonState) {
        switch state {
            case .standby:
                if let pointAnnotation = mapView.annotations.first(where: { $0 is MKPointAnnotation }) {
                    mapView.removeAnnotation(pointAnnotation)
                }
                mapView.gestureRecognizers?.forEach { mapView.removeGestureRecognizer($0) }

            case .selecting:
                mapView.addGestureRecognizer(
                    UILongPressGestureRecognizer(
                        target: self,
                        action: #selector(didMapViewLongPressed(_:))
                    )
                )
        }
    }
    
    private func updateLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        mapView.setRegion(
            .init(center: location.coordinate, span: span),
            animated: true
        )
    }

    @objc private func didMapViewLongPressed(_ sender: UILongPressGestureRecognizer) {

        if
            let pointAnnotation = mapView.annotations.first(where: { $0 is MKPointAnnotation })
        {
            mapView.removeAnnotations([pointAnnotation])
        }

        let rockAddressPin = MKPointAnnotation()
        let tapPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        rockAddressPin.coordinate = coordinate
        mapView.addAnnotation(rockAddressPin)
        mapView.selectAnnotation(rockAddressPin, animated: false)

        viewModel.location = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
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
        
        let vc = RockDetailViewController.createInstance(viewModel: .init(rock: rockAnnotation.rock))
        navigationController?.pushViewController(vc, animated: true)
    }
}

class RockAnnotation: NSObject, MKAnnotation {
    
    let rock: FIDocument.Rock
    let coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(
        coordinate: CLLocationCoordinate2D,
        rock: FIDocument.Rock,
        title: String
    ) {
        self.rock = rock
        self.coordinate = coordinate
        self.title = title
    }
}
