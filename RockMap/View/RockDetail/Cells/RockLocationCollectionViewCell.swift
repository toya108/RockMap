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
    lazy var trackingButton: MKUserTrackingButton = {
        return .init(mapView: mapView)
    }()
    
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
    
    func configure(locationStructure: LocationManager.LocationStructure) {
        addressLabel.text = locationStructure.address
        
        mapView.setRegion(
            .init(
                center: locationStructure.location.coordinate,
                span: span
            ),
            animated: false
        )
        
        let rockAnnotation = MKPointAnnotation()
        rockAnnotation.coordinate = locationStructure.location.coordinate
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
        mapView.layer.cornerRadius = 8
        
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
    }
}
