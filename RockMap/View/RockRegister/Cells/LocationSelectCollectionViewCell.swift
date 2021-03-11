//
//  LocationSelectCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/11.
//

import UIKit
import MapKit

class LocationSelectCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapBaseView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var currentAddressButton: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        currentAddressButton.layer.cornerRadius = 8
        mapBaseView.layer.cornerRadius = 8
    }
    
    func configure(locationStructure: RockRegisterViewModel.LocationStructure) {
        addressLabel.text = locationStructure.address
        
        mapView.setRegion(
            .init(
                center: locationStructure.location.coordinate,
                span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)
            ),
            animated: true
        )
        
        mapView.removeAnnotations(mapView.annotations)
        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = locationStructure.location.coordinate
        mapView.addAnnotation(rockAddressPin)
    }

}
