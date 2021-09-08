import MapKit
import UIKit

class LocationSelectCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapBaseView: UIView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var currentAddressButton: UIButton!
    @IBOutlet var selectLocationButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.currentAddressButton.layer.cornerRadius = 8
        self.mapBaseView.layer.cornerRadius = 8
    }

    func configure(locationStructure: LocationManager.LocationStructure) {
        self.addressLabel.text = locationStructure.address

        self.mapView.setRegion(
            .init(
                center: locationStructure.location.coordinate,
                span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001)
            ),
            animated: true
        )

        self.mapView.removeAnnotations(self.mapView.annotations)
        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = locationStructure.location.coordinate
        self.mapView.addAnnotation(rockAddressPin)
    }
}
