//
//  ViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/03.
//

import Combine
import UIKit
import MapKit
import FloatingPanel

final class RockSearchViewController: UIViewController {

    private var viewModel: RockSearchViewModel!
    private var router: RockSeachRouter!
    private var bindings = Set<AnyCancellable>()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var addressBaseView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressBaseViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    private let floatingPanelVc = FloatingPanelController()

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

    static func createInstance(viewModel: RockSearchViewModel) -> RockSearchViewController {
        let storyboard = UIStoryboard(name: RockSearchViewController.className, bundle: nil)

        let instance = storyboard.instantiateInitialViewController() as! RockSearchViewController
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBindings()
        setupMapView()
        setupSearchBar()
        setupFloatingPanel()
        updateLocation(LocationManager.shared.location)
        setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationBar()
        viewModel.fetchRockList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        viewModel.locationSelectState = .standby
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.placeholder = "地名を入力"
        searchBar.addShadow()
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

        func setupAddressBaseView() {
            addressBaseView.addShadow()
            addressBaseView.layer.cornerRadius = 16
            addressLabel.layer.cornerRadius = 8
        }

        setupTrackingButton()
        setupSelectLocationButton()
        setupAddressBaseView()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: RockAnnotation.className
        )
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
    
    private func setupBindings() {
        viewModel.$rockDocuments
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
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
            .store(in: &bindings)

        viewModel.$address
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
                addressLabel.text = nil

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
        mapView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(didMapViewLongPressed(_:))
            )
        )
    }

    @objc private func didMapViewLongPressed(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began { return }

        if viewModel.locationSelectState == .standby {
            viewModel.locationSelectState = .selecting
        }

        if let pointAnnotation = mapView.annotations.first(where: { $0 is MKPointAnnotation }) {
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
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        let annotationView: MKAnnotationView

        switch annotation {
            case let rockAnnotation as RockAnnotation:
                annotationView = makeRockAnnotationView(for: rockAnnotation, on: mapView)

            case let clusterAnnotation as MKClusterAnnotation:
                annotationView = makeRockClusterAnnotationView(for: clusterAnnotation, on: mapView)

            case let pointAnnotation as MKPointAnnotation:
                annotationView = makePointAnnotationView(for: pointAnnotation, on: mapView)

            default:
                annotationView = MKMarkerAnnotationView()
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        floatingPanelVc.removePanelFromParent(animated: true)
    }

    func mapView(
        _ mapView: MKMapView,
        didSelect view: MKAnnotationView
    ) {
        switch view.annotation {
            case let rockAnnotation as RockAnnotation:
                showFloatingPanel(rocks: [rockAnnotation.rock])

            case let clusterAnnotation as MKClusterAnnotation:
                showFloatingPanel(
                    rocks: clusterAnnotation.memberAnnotations.compactMap { $0 as? RockAnnotation  }.map(\.rock)
                )

            default:
                break

        }
    }

    private func showFloatingPanel(rocks: [FIDocument.Rock]) {

        if floatingPanelVc.contentViewController == nil {
            addFloatingPanel(rocks: rocks)
            return
        }

        floatingPanelVc.removePanelFromParent(animated: true) { [weak self] in

            guard let self = self else { return }

            self.addFloatingPanel(rocks: rocks)
        }
    }

    private func addFloatingPanel(rocks: [FIDocument.Rock]) {
        let contentVC = RockAnnotationListViewController.createInstance(rocks: rocks)
        contentVC.delegate = self
        floatingPanelVc.set(contentViewController: contentVC)
        floatingPanelVc.track(scrollView: contentVC.collectionView)
        floatingPanelVc.addPanel(toParent: self, animated: true)
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
        button.addAction(
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
        button.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        button.setTitle("ここに岩を登録する", for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor.Pallete.primaryPink
        markerAnnotationView.detailCalloutAccessoryView = button

        return markerAnnotationView
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
        return [.half: FloatingPanelLayoutAnchor(fractionalInset: 0.35, edge: .bottom, referenceGuide: .safeArea)]
    }
}

extension RockSearchViewController: RockAnnotationTableViewDelegate {

    func didSelectRockAnnotaitonCell(rock: FIDocument.Rock) {
        router.route(to: .rockDetail(rock), from: self)
    }

}

extension RockSearchViewController: RockRegisterDetectableViewControllerProtocol {

    func didRockRegisterFinished() {
        viewModel.locationSelectState = .standby
        viewModel.fetchRockList()
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
            }
            .store(in: &bindings)
    }
}
