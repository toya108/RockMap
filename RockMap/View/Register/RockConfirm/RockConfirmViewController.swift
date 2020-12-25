//
//  RockConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import UIKit
import MapKit
import Combine

final class RockConfirmViewController: UIViewController {
    
    @IBOutlet weak var rockImageScrollView: UIScrollView!
    @IBOutlet weak var rockImageStackView: UIStackView!
    @IBOutlet weak var rockNameLabel: UILabel!
    @IBOutlet weak var rockDescLabel: UILabel!
    @IBOutlet weak var rockAddressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var registButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var viewModel: RockConfirmViewModel = .init()
    private var bindings = Set<AnyCancellable>()
    
    init?(coder: NSCoder, viewModel: RockConfirmViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRockDatas()
        setupLayout()
        bindViewModelToView()
    }
    
    @IBAction func registButtonTapped(_ sender: UIButton) {
        viewModel.uploadImages()
    }
    
    private func setupRockDatas() {
        func setupLabels() {
            rockNameLabel.text = viewModel.rockName
            rockDescLabel.text = viewModel.rockDesc
            rockAddressLabel.text = viewModel.rockAddress
        }
        
        func setupMap() {
            let rockAddressPin = MKPointAnnotation()
            rockAddressPin.coordinate = viewModel.rockLocation.coordinate
            self.mapView.addAnnotation(rockAddressPin)
            let span = MKCoordinateSpan(latitudeDelta: Const.Map.latitudeDelta, longitudeDelta: Const.Map.longitudeDelta)
            self.mapView.setRegion(.init(center: viewModel.rockLocation.coordinate, span: span), animated: true)
        }

        func setupImages() {
            rockImageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            viewModel.rockImageDatas.forEach {
                let imageView = makeImageView(data: $0)
                rockImageStackView.addArrangedSubview(imageView)
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
                    imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 9/16)
                ])
            }
        }
        
        setupLabels()
        setupMap()
        setupImages()
    }
    
    private func bindViewModelToView() {
        viewModel.$imageUploadState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                
                guard let self = self else { return }
                
                switch $0 {
                case .stanby:
                    self.indicator.stopAnimating()
                    
                case .progress(let unitCount):
                    self.indicator.startAnimating()
                    
                case .complete:
                    self.indicator.stopAnimating()
                    
                case .failure(let error):
                    self.indicator.stopAnimating()
                    self.showOKAlert(
                        title: "登録に失敗しました",
                        message: error.localizedDescription
                    )
                    
                }
            }
            .store(in: &bindings)
    }
    
    private func makeImageView(data: Data) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(data: data)
        return imageView
    }
    
    private func setupLayout() {
        navigationItem.title = "登録内容の確認"
        registButton.layer.cornerRadius = 8
        mapView.layer.cornerRadius = 8
    }
}
