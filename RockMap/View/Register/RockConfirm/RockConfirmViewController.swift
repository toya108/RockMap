//
//  RockConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/23.
//

import UIKit
import MapKit

final class RockConfirmViewController: UIViewController {
    
    @IBOutlet weak var rockImageScrollView: UIScrollView!
    @IBOutlet weak var rockImageStackView: UIStackView!
    @IBOutlet weak var rockNameLabel: UILabel!
    @IBOutlet weak var rockDescLabel: UILabel!
    @IBOutlet weak var rockAddressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var registButton: UIButton!
    
    private let viewModel: RockConfirmViewModel
    
    init?(coder: NSCoder, viewModel: RockConfirmViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRockDatas()
        setupLayout()
    }
    
    private func setupRockDatas() {
        rockNameLabel.text = viewModel.rockName
        rockDescLabel.text = viewModel.rockDesc
        rockAddressLabel.text = viewModel.rockAddress
        
        let rockAddressPin = MKPointAnnotation()
        rockAddressPin.coordinate = viewModel.rockLocation.coordinate
        self.mapView.addAnnotation(rockAddressPin)
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        self.mapView.setRegion(.init(center: viewModel.rockLocation.coordinate, span: span), animated: true)

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
