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
    
    private var bindings = Set<AnyCancellable>()
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    
    @IBOutlet weak var locationSelectMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
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
        navigationItem.setLeftBarButton(.init(title: "戻る", style: .plain, target: self, action: #selector(didCancelButtonTapped)), animated: true)
        navigationItem.setRightBarButton(.init(title: "完了", style: .done, target: self, action: #selector(didCompleteButtonTapped)), animated: true)
    }
    
    private func setupBindings() {
        $location
            .sink { location in
                LocationManager.shared.reverseGeocoding(location: location) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let address):
                        self.address = address
                        self.addressLabel.text = "📍 " + address
                        
                    case .failure:
                        break
                        
                    }
                }
            }
            .store(in: &bindings)
    }
    
    private func setupMapView() {
        locationSelectMapView.setRegion(.init(center: location.coordinate, span: span), animated: true)
        
        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = location.coordinate
        locationSelectMapView.addAnnotation(rockAddressPin)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didMapViewLongPressed(_:)))
        locationSelectMapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc private func didCompleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self = self,
                  let presenting = self.topViewController(controller: UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController ) as? RockRegisterViewController else { return }
            presenting.rockAddressTextView.text = self.address
            presenting.viewModel.rockLocation = self.location
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
        locationSelectMapView.setRegion(.init(center: coordinate, span: span), animated: true)
    }
}
