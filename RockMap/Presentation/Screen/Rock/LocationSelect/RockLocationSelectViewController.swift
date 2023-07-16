import Combine
import MapKit
import UIKit

protocol LocationSelectDelegate: AnyObject {
    func didFinishSelectLocation(location: CLLocation, address: String)
}

class RockLocationSelectViewController: UIViewController {

    @Published private var location = LocationManager.shared.location
    private var address = ""
    private var prefecture = ""

    private var bindings = Set<AnyCancellable>()
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)

    private weak var delegate: LocationSelectDelegate?

    @IBOutlet var locationSelectMapView: MKMapView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var mapView: MKMapView!

    private lazy var trackingButton: MKUserTrackingButton = {
        .init(mapView: mapView)
    }()

    init?(coder: NSCoder, location: CLLocation, delegate: LocationSelectDelegate?) {
        self.location = location
        self.delegate = delegate
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupBindings()
        self.setupMapView()
    }

    private func setupNavigationBar() {
        navigationItem.title = "岩の位置を選択する"
        let closeButton = UIBarButtonItem(
            image: Resources.Images.System.xmark.uiImage,
            style: .plain,
            target: self,
            action: #selector(self.didCancelButtonTapped)
        )
        closeButton.tintColor = .label
        navigationItem.setLeftBarButton(closeButton, animated: true)

        let doneButton = UIBarButtonItem(
            title: "完了",
            style: .done,
            target: self,
            action: #selector(self.didCompleteButtonTapped)
        )
        doneButton.tintColor = UIColor.Pallete.primaryGreen
        navigationItem.setRightBarButton(doneButton, animated: true)
    }

    private func setupBindings() {
        $location
            .removeDuplicates()
            .flatMap {
                LocationManager.shared.reverseGeocoding(location: $0)
                    .catch { _ in
                        Empty()
                    }
            }
            .sink { [weak self] placemark in

                guard let self = self else { return }

                self.address = placemark.address
                self.prefecture = placemark.prefecture
                self.addressLabel.text = "📍 " + placemark.address
            }
            .store(in: &self.bindings)
    }

    private func setupMapView() {
        self.mapView.delegate = self

        self.trackingButton.tintColor = UIColor.Pallete.primaryGreen
        self.trackingButton.backgroundColor = .tertiarySystemBackground
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

        self.locationSelectMapView.setRegion(
            .init(center: self.location.coordinate, span: self.span),
            animated: true
        )

        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = self.location.coordinate
        self.locationSelectMapView.addAnnotation(rockAddressPin)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.didMapViewLongPressed(_:))
        )
        self.locationSelectMapView.addGestureRecognizer(longPressGestureRecognizer)
    }

    @objc private func didCompleteButtonTapped() {
        dismiss(animated: true)
        delegate?.didFinishSelectLocation(location: self.location, address: self.address)
    }

    @objc private func didCancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func didMapViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        self.locationSelectMapView.removeAnnotations(self.locationSelectMapView.annotations)

        let rockAddressPin = MKPointAnnotation()
        let tapPoint = sender.location(in: self.locationSelectMapView)
        let coordinate = self.locationSelectMapView.convert(
            tapPoint,
            toCoordinateFrom: self.locationSelectMapView
        )
        rockAddressPin.coordinate = coordinate
        self.locationSelectMapView.addAnnotation(rockAddressPin)

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
