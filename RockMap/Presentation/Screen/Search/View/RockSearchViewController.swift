import Combine
import MapKit
import UIKit
import FloatingPanel
import SwiftUI

final class RockSearchViewController: UIViewController {
    private var viewModel: RockSearchViewModel!
    private var router: RockSeachRouter!
    private var bindings = Set<AnyCancellable>()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var buttonStackView: UIStackView!
    @IBOutlet var addressBaseView: UIView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var addressBaseViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var searchBar: UISearchBar!
    private let floatingPanelVc = FloatingPanelController()

    private lazy var trackingButton: MKUserTrackingButton = {
        .init(mapView: mapView)
    }()

    @IBOutlet var selectLocationButton: UIButton!

    @IBAction func selectLocationButtonTapped(_ sender: UIButton) {
        if self.viewModel.locationSelectState == .standby {
            self.viewModel.locationSelectState = .selecting
        } else {
            self.viewModel.locationSelectState = .standby
        }
    }

    static func createInstance(viewModel: RockSearchViewModel) -> RockSearchViewController {
        let storyboard = UIStoryboard(name: RockSearchViewController.className, bundle: nil)

        let instance = storyboard.instantiateInitialViewController() as! RockSearchViewController
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupLayout()
        self.setupBindings()
        self.setupMapView()
        self.setupFloatingPanel()
        self.setupSearchBar()
        self.updateLocation(LocationManager.shared.location)
        self.setupLongPressGesture()
        self.setupNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupNavigationBar()
        self.viewModel.fetchRockList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.viewModel.locationSelectState = .standby
    }

    private func setupNotification() {
        NotificationCenter.default
            .publisher(for: .didRockRegisterFinished)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.locationSelectState = .standby
                self.viewModel.fetchRockList()
            }
            .store(in: &bindings)
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.searchTextField.backgroundColor = .tertiarySystemBackground
        self.searchBar.placeholder = "地名を入力"
        self.searchBar.addShadow()
    }

    private func setupLayout() {
        func setupTrackingButton() {
            self.trackingButton.tintColor = UIColor.Pallete.primaryGreen
            self.trackingButton.backgroundColor = .tertiarySystemBackground
            self.trackingButton.layer.cornerRadius = 4
            self.trackingButton.addShadow()

            self.trackingButton.translatesAutoresizingMaskIntoConstraints = false
            self.buttonStackView.addArrangedSubview(self.trackingButton)
            NSLayoutConstraint.activate([
                self.trackingButton.heightAnchor.constraint(equalToConstant: 44),
                self.trackingButton.widthAnchor.constraint(equalToConstant: 44)
            ])
        }

        func setupSelectLocationButton() {
            self.selectLocationButton.layer.cornerRadius = 22
            self.selectLocationButton.addShadow()
        }

        func setupAddressBaseView() {
            self.addressBaseView.addShadow()
            self.addressBaseView.layer.cornerRadius = 16
            self.addressBaseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.addressLabel.layer.cornerRadius = 8
        }

        setupTrackingButton()
        setupSelectLocationButton()
        setupAddressBaseView()
    }

    private func setupFloatingPanel() {
        floatingPanelVc.delegate = self
        floatingPanelVc.isRemovalInteractionEnabled = true

        let appearence = SurfaceAppearance()
        appearence.cornerRadius = 16
        let shadow = SurfaceAppearance.Shadow()
        shadow.radius = Resources.Const.UI.Shadow.radius
        shadow.opacity = 0.3
        appearence.shadows = [shadow]
        floatingPanelVc.surfaceView.appearance = appearence
    }

    private func setupMapView() {
        self.mapView.delegate = self
        self.mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: RockAnnotation.className
        )
    }

    private func setupBindings() {
        self.viewModel.$rockDocuments
            .dropFirst()
            .removeDuplicates()
            .map { rocks in
                rocks.map { RockAnnotation(rock: $0) }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] annotations in

                guard let self = self else { return }

                self.mapView.removeAnnotations(self.mapView.annotations)

                annotations.forEach {
                    self.mapView.addAnnotation($0)
                }
            }
            .store(in: &self.bindings)

        self.viewModel.$locationSelectState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in

                guard let self = self else { return }

                self.updateSelectButtonLayout(state: state)
                self.updateMapView(state: state)
                let baseViewHeight = self.addressBaseView.bounds.height

                self.addressBaseViewTopConstraint.constant = state == .selecting
                    ? -baseViewHeight
                    : 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &self.bindings)

        self.viewModel.$address
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] address in

                guard
                    let self = self,
                    let address = address
                else {
                    return
                }

                self.addressLabel.text = "📍" + address
            }
            .store(in: &self.bindings)
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
            if let pointAnnotation = mapView.annotations.first(
                where: { $0 is MKPointAnnotation }
            ) {
                self.mapView.removeAnnotation(pointAnnotation)
            }
            self.addressLabel.text = nil

        case .selecting:
            break
        }
    }

    private func updateLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

        mapView.setRegion(
            .init(center: location.coordinate, span: span),
            animated: true
        )
    }

    private func setupLongPressGesture() {
        self.mapView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(self.didMapViewLongPressed(_:))
            )
        )
    }

    @objc private func didMapViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began { return }

        let tapPoint = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(tapPoint, toCoordinateFrom: self.mapView)

        self.addPinToTarget(coordinate: coordinate)
    }

    private func addPinToTarget(coordinate: CLLocationCoordinate2D) {
        if self.viewModel.locationSelectState == .standby {
            self.viewModel.locationSelectState = .selecting
        }

        if let pointAnnotation = mapView.annotations.first(where: { $0 is MKPointAnnotation }) {
            self.mapView.removeAnnotations([pointAnnotation])
        }

        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = coordinate
        self.mapView.addAnnotation(rockAddressPin)
        self.mapView.selectAnnotation(rockAddressPin, animated: false)

        self.viewModel.location = .init(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

    private func showFloatingPanel(rocks: [Entity.Rock]) {

        if floatingPanelVc.contentViewController == nil {
            addFloatingPanel(rocks: rocks)
            return
        }

        floatingPanelVc.removePanelFromParent(animated: true) { [weak self] in

            guard let self = self else { return }

            self.addFloatingPanel(rocks: rocks)
        }
    }

    private func addFloatingPanel(rocks: [Entity.Rock]) {
        let contentVC = UIHostingController(rootView: RockAnnotationListView(rocks: rocks))
        contentVC.rootView.delegate = self
        floatingPanelVc.set(contentViewController: contentVC)
        floatingPanelVc.addPanel(toParent: self, animated: true)
    }

}

extension RockSearchViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        let annotationView: MKAnnotationView

        switch annotation {
        case let rockAnnotation as RockAnnotation:
            annotationView = self.makeRockAnnotationView(for: rockAnnotation, on: mapView)

        case let clusterAnnotation as MKClusterAnnotation:
            annotationView = self.makeRockClusterAnnotationView(
                for: clusterAnnotation,
                on: mapView
            )

        case let pointAnnotation as MKPointAnnotation:
            annotationView = self.makePointAnnotationView(for: pointAnnotation, on: mapView)

        default:
            annotationView = MKMarkerAnnotationView()
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.floatingPanelVc.removePanelFromParent(animated: true)
    }

    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        switch view.annotation {
        case let rockAnnotation as RockAnnotation:
            self.showFloatingPanel(rocks: [rockAnnotation.rock])

        case let clusterAnnotation as MKClusterAnnotation:
            self.showFloatingPanel(
                rocks: clusterAnnotation.memberAnnotations
                    .compactMap { $0 as? RockAnnotation }
                    .map(\.rock)
            )

        default:
            break
        }
    }

    private func makeRockAnnotationView(
        for annotation: RockAnnotation,
        on mapView: MKMapView
    ) -> MKAnnotationView {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: RockAnnotation.className,
            for: annotation
        )

        guard
            let markerAnnotationView = view as? MKMarkerAnnotationView
        else {
            return view
        }

        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryGreen
        markerAnnotationView.clusteringIdentifier = RockAnnotation.className
        return markerAnnotationView
    }

    private func makeRockClusterAnnotationView(
        for annotation: MKClusterAnnotation,
        on mapView: MKMapView
    ) -> MKAnnotationView {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
            for: annotation
        )

        guard
            let markerAnnotationView = view as? MKMarkerAnnotationView
        else {
            return view
        }

        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryGreen
        return markerAnnotationView
    }

    private func makePointAnnotationView(
        for annotation: MKPointAnnotation,
        on mapView: MKMapView
    ) -> MKAnnotationView {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        )

        guard
            let markerAnnotationView = view as? MKMarkerAnnotationView
        else {
            return view
        }
        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryPink
        markerAnnotationView.canShowCallout = true
        let button = UIButton()
        button.addActionForOnce(
            .init { [weak self] _ in

                guard let self = self else { return }

                let location = CLLocation(
                    latitude: annotation.coordinate.latitude,
                    longitude: annotation.coordinate.longitude
                )
                self.router.route(
                    to: .rockRegister(location),
                    from: self
                )
            },
            for: .touchUpInside
        )
        // if I use button configutation, insets is not work in detailCalloutAccessoryView.
        button.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        button.setTitle("ここに岩を登録する", for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.Pallete.primaryPink
        markerAnnotationView.detailCalloutAccessoryView = button

        return markerAnnotationView
    }
}

extension RockSearchViewController: RockAnnotationTableViewDelegate {
    func didSelectRockAnnotaitonCell(rock: Entity.Rock) {
        floatingPanelVc.removeFromParent()
        self.router.route(to: .rockDetail(rock), from: self)
    }
}

extension RockSearchViewController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        LocationManager.shared
            .geocoding(address: searchText)
            .removeDuplicates()
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .sink { [weak self] location in

                guard let self = self else { return }

                self.updateLocation(location)
                self.addPinToTarget(coordinate: location.coordinate)
            }
            .store(in: &self.bindings)
    }
}

extension RockSearchViewController: FloatingPanelControllerDelegate {

    func floatingPanel(
        _ fpc: FloatingPanelController,
        layoutFor newCollection: UITraitCollection
    ) -> FloatingPanelLayout {
        return RockSearchFloatingPanelLayout()
    }

}

class RockSearchFloatingPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(
                absoluteInset: 16.0,
                edge: .top,
                referenceGuide: .safeArea
            ),
            .half: FloatingPanelLayoutAnchor(
                fractionalInset: 0.3,
                edge: .bottom,
                referenceGuide: .safeArea
            ),
            .tip: FloatingPanelLayoutAnchor(
                absoluteInset: 44.0,
                edge: .bottom,
                referenceGuide: .safeArea
            )
        ]
    }
}
