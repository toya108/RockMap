//
//  RockLocationSelectViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/08.
//

import UIKit
import MapKit
import Combine

class RockLocationSelectViewController: UIViewController {
    
    @Published private var location = LocationManager.shared.location
    private var address = ""
    private var prefecture = ""
    
    private var bindings = Set<AnyCancellable>()
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    
    @IBOutlet weak var locationSelectMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    private lazy var trackingButton: MKUserTrackingButton = {
        return .init(mapView: mapView)
    }()
    
    init?(coder: NSCoder, location: CLLocation) {
        self.location = location
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupBindings()
        setupMapView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "岩の位置を選択する"
        navigationItem.setLeftBarButton(
            .init(
                image: UIImage.SystemImages.xmark,
                style: .plain,
                target: self,
                action: #selector(didCancelButtonTapped)
            ),
            animated: true
        )
        
        let doneButton = UIBarButtonItem(
            title: "完了",
            style: .done,
            target: self,
            action: #selector(didCompleteButtonTapped)
        )
        doneButton.tintColor = UIColor.Pallete.primaryGreen
        navigationItem.setRightBarButton(doneButton, animated: true)
    }
    
    private func setupBindings() {
        $location
            .removeDuplicates()
            .flatMap {
                LocationManager.shared.reverseGeocoding(location: $0)
            }
            .catch { _ -> Just<CLPlacemark> in
                return .init(.init())
            }
            .sink { [weak self] placemark in

                guard let self = self else { return }

                self.address = placemark.address
                self.prefecture = placemark.prefecture
                self.addressLabel.text = "📍 " + placemark.address
            }
            .store(in: &bindings)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        
        trackingButton.tintColor = UIColor.Pallete.primaryGreen
        trackingButton.backgroundColor = .white
        trackingButton.layer.cornerRadius = 4
        trackingButton.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        trackingButton.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        trackingButton.layer.shadowColor = Resources.Const.UI.Shadow.color
        trackingButton.layer.shadowOffset = .init(width: 4, height: 4)
        
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(trackingButton)
        NSLayoutConstraint.activate([
            trackingButton.heightAnchor.constraint(equalToConstant: 44),
            trackingButton.widthAnchor.constraint(equalToConstant: 44),
            trackingButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -8),
            trackingButton.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -8)
        ])
        
        locationSelectMapView.setRegion(.init(center: location.coordinate, span: span), animated: true)
        
        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = location.coordinate
        locationSelectMapView.addAnnotation(rockAddressPin)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didMapViewLongPressed(_:)))
        locationSelectMapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc private func didCompleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            
            guard
                let self = self,
                let presenting = self.topViewController(
                    controller: UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
                ) as? RockRegisterViewController
            else {
                return
            }
            
            presenting.viewModel.input.locationSubject.send(
                .init(location: self.location, address: self.address)
            )
        }
    }
    
    @objc private func didCancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func didMapViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        locationSelectMapView.removeAnnotations(locationSelectMapView.annotations)
        
        let rockAddressPin = MKPointAnnotation()
        let tapPoint = sender.location(in: locationSelectMapView)
        let coordinate = locationSelectMapView.convert(tapPoint, toCoordinateFrom: locationSelectMapView)
        rockAddressPin.coordinate = coordinate
        locationSelectMapView.addAnnotation(rockAddressPin)
        
        self.location = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension RockLocationSelectViewController: MKMapViewDelegate {
    
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

        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryGreen
        return markerAnnotationView
    }
    
}
