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
    
    private var viewModel: RockConfirmViewModel!
    private var bindings = Set<AnyCancellable>()
    
    static func createInstance(viewModel: RockConfirmViewModel) -> RockConfirmViewController {
        let vc = UIStoryboard(name: RockConfirmViewController.className, bundle: nil).instantiateInitialViewController() as? RockConfirmViewController
        vc?.viewModel = viewModel
        return vc!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRockDatas()
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
            let span = MKCoordinateSpan(
                latitudeDelta: Resources.Const.Map.latitudeDelta,
                longitudeDelta: Resources.Const.Map.longitudeDelta
            )
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
                    
                case .complete(let metaDatas):
                    self.indicator.stopAnimating()
                    self.viewModel.registerRock()
                    
                case .failure(let error):
                    self.indicator.stopAnimating()
                    self.showOKAlert(
                        title: "画像の登録に失敗しました",
                        message: error.localizedDescription
                    )
                    
                }
            }
            .store(in: &bindings)
        
        viewModel.$rockUploadState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                
                guard let self = self else { return }
                
                switch $0 {
                case .stanby:
                    break
                    
                case .loading:
                    self.indicator.startAnimating()
                    
                case .finish:
                    self.indicator.stopAnimating()
                    RegisterSucceededViewController.showSuccessView(present: self) {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            
                            guard let self = self else { return }
                            
                            self.dismiss(animated: true) { [weak self] in
                                
                                guard let self = self else { return }
                                
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self.showOKAlert(
                        title: "岩の登録に失敗しました",
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
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private func setupLayout() {
        navigationItem.title = "登録内容の確認"
        registButton.layer.cornerRadius = Resources.Const.UI.View.radius
        mapView.layer.cornerRadius = Resources.Const.UI.View.radius
    }
}

extension RockConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}
