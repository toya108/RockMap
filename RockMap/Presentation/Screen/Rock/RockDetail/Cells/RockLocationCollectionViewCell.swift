import MapKit
import UIKit

class RockLocationCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let addressLabel = UILabel()
    let mapView = MKMapView()
    lazy var trackingButton: MKUserTrackingButton = {
        .init(mapView: mapView)
    }()

    var location: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    func configure(locationStructure: LocationManager.LocationStructure) {
        self.addressLabel.text = locationStructure.address

        self.mapView.setRegion(
            .init(
                center: locationStructure.location.coordinate,
                span: self.span
            ),
            animated: false
        )

        let rockAnnotation = MKPointAnnotation()
        rockAnnotation.coordinate = locationStructure.location.coordinate
        self.mapView.addAnnotation(rockAnnotation)
    }

    private func setupLayout() {
        addSubview(self.stackView)
        self.stackView.axis = .vertical
        self.stackView.spacing = 16
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        self.stackView.addArrangedSubview(self.addressLabel)
        self.addressLabel.numberOfLines = 0
        self.addressLabel.textColor = .darkGray
        self.addressLabel.font = UIFont.preferredFont(forTextStyle: .body)

        self.stackView.addArrangedSubview(self.mapView)
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapView.heightAnchor.constraint(equalToConstant: bounds.width * 9 / 16)
        ])
        self.mapView.showsUserLocation = true
        self.mapView.layer.cornerRadius = 8

        self.trackingButton.tintColor = UIColor.Pallete.primaryGreen
        self.trackingButton.backgroundColor = .white
        self.trackingButton.layer.cornerRadius = 4
        self.trackingButton.layer.shadowRadius = Resources.Const.UI.Shadow.radius
        self.trackingButton.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        self.trackingButton.layer.shadowColor = Resources.Const.UI.Shadow.color
        self.trackingButton.layer.shadowOffset = .init(width: 4, height: 4)

        self.trackingButton.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.addSubview(self.trackingButton)
        NSLayoutConstraint.activate([
            self.trackingButton.heightAnchor.constraint(equalToConstant: 44),
            self.trackingButton.widthAnchor.constraint(equalToConstant: 44),
            self.trackingButton.bottomAnchor.constraint(
                equalTo: self.mapView.bottomAnchor,
                constant: -8
            ),
            self.trackingButton.rightAnchor.constraint(
                equalTo: self.mapView.rightAnchor,
                constant: -8
            )
        ])
    }
}
