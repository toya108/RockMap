//
//  RockLocationCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/07.
//

import UIKit
import MapKit

class RockLocationCollectionViewCell: UICollectionViewCell {
    
    let stackView = UIStackView()
    let addressLabel = UILabel()
    let mapView = MKMapView()
    
    var location: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    func configure(rockLocation: RockDetailViewModel.RockLocation) {
        addressLabel.text = rockLocation.address
        
        let location = CLLocationCoordinate2D(latitude: rockLocation.latitude, longitude: rockLocation.longitude)
        
        mapView.setRegion(
            .init(
                center: location,
                span: span
            ),
            animated: false
        )
        
        let rockAnnotation = MKPointAnnotation()
        rockAnnotation.coordinate = location
        mapView.addAnnotation(rockAnnotation)
    }
    
    private func setupLayout() {
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        stackView.addArrangedSubview(addressLabel)
        addressLabel.numberOfLines = 0
        addressLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        stackView.addArrangedSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.heightAnchor.constraint(equalToConstant: bounds.width * 9/16)
        ])
        
        mapView.showsUserLocation = true
    }
    
    
}
