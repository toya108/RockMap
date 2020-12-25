//
//  RockRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/01.
//

import UIKit
import Combine
import MapKit
import PhotosUI

final class RockRegisterViewController: UIViewController {

    @IBOutlet weak var backScrollView: TouchableScrollView!
    @IBOutlet weak var backStackView: UIStackView!
    @IBOutlet weak var rockNameTextField: UITextField!
    @IBOutlet weak var rockNameErrorLabel: UILabel!
    @IBOutlet weak var firstImageSelectStackView: UIStackView!
    @IBOutlet weak var firstImageUploadButton: UIButton!
    @IBOutlet weak var rockImageErrorLabel: UILabel!
    @IBOutlet weak var imageSelectHorizontalScrollView: UIScrollView!
    @IBOutlet weak var imageHorizontalStackView: UIStackView!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var rockAddressTextView: UITextView!
    @IBOutlet weak var rockAddressErrorLabel: UILabel!
    @IBOutlet weak var currentAddressButton: UIButton!
    @IBOutlet weak var mapBaseView: UIView!
    @IBOutlet weak var rockRegisterMapView: MKMapView!
    @IBOutlet weak var rockDescTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    let viewModel = RockRegisterViewModel()
    private let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    private var bindings = Set<AnyCancellable>()
    
    private let phPickerViewController: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        return PHPickerViewController(configuration: configuration)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupLayout()
        setupKeyboard()
        setupImageUploadButtonActions()
        bindViewToViewModel()
        bindViewModelToView()
        
        rockAddressTextView.setText(text: LocationManager.shared.address)
    }
    
    private func setupImageUploadButtonActions() {
        let photoLibraryAction = UIAction(
            title: "フォトライブラリ",
            image: UIImage.AssetsImages.folderFill
        ) { [weak self] _ in
            
            guard let self = self else { return }

            self.present(self.phPickerViewController, animated: true)
        }
        
        let cameraAction = UIAction(
            title: "写真を撮る",
            image: UIImage.AssetsImages.cameraFill
        ) { [weak self] _ in
            
            guard let self = self else { return }
            
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            self.present(vc, animated: true)
        }
        
        let menu = UIMenu(title: "", children: [photoLibraryAction, cameraAction])
        [imageUploadButton, firstImageUploadButton].forEach {
            $0?.menu = menu
            $0?.showsMenuAsPrimaryAction = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func didCurrentAddressButtonTapped(_ sender: UIButton) {
        rockAddressTextView.setText(text: LocationManager.shared.address)
    }
    
    @IBAction func didAddressSelectButtonTapped(_ sender: UIButton) {
        guard let vc = (UIStoryboard(name: RockLocationSelectViewController.className, bundle: nil).instantiateInitialViewController { [weak self] coder in
            
            guard let self = self else { return RockLocationSelectViewController(coder: coder) }
            
            return RockLocationSelectViewController(coder: coder, location: self.viewModel.rockLocation)
        }) else { return }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @IBAction func didConfirmButtonTapped(_ sender: UIButton) {
        guard let vc = (UIStoryboard(name: RockConfirmViewController.className, bundle: nil).instantiateInitialViewController { [weak self] coder in
            
            guard let self = self else { return RockConfirmViewController(coder: coder) }
            
            return RockConfirmViewController(
                coder: coder,
                viewModel: .init(
                    rockName: self.viewModel.rockName,
                    rockImageDatas: self.viewModel.rockImageDatas,
                    rockAddress: self.viewModel.rockAddress,
                    rockLocation: self.viewModel.rockLocation,
                    rockDesc: self.viewModel.rockDesc
                )
            )
        }) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupDelegate() {
        rockNameTextField.delegate = self
        phPickerViewController.delegate = self
    }
    
    private func setupLayout() {
        navigationItem.title = "岩を登録する"
        
        [firstImageUploadButton,
         currentAddressButton,
         mapBaseView,
         imageUploadButton,
         confirmButton
        ]
        .forEach { $0?.layer.cornerRadius = 8 }
    }
    
    private func bindViewToViewModel() {
        rockNameTextField.textDidChangedPublisher.assign(to: &viewModel.$rockName)
        rockAddressTextView.textDidChangedPublisher.assign(to: &viewModel.$rockAddress)
        rockDescTextView.textDidChangedPublisher.assign(to: &viewModel.$rockDesc)
    }
    
    private func bindViewModelToView() {
        viewModel.$rockImageDatas
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                
                guard let self = self else { return }
                
                self.firstImageSelectStackView.isHidden = !data.isEmpty
                self.imageSelectHorizontalScrollView.isHidden = data.isEmpty
                
                if data.isEmpty { return }
                
                self.imageHorizontalStackView.arrangedSubviews
                    .filter { $0.self is UIImageView }
                    .forEach { $0.removeFromSuperview() }
                
                data.forEach {
                    let deletableImageView = self.makeDeletableImageView(data: $0)
                    self.imageHorizontalStackView.addArrangedSubview(deletableImageView)
                    NSLayoutConstraint.activate([
                        deletableImageView.widthAnchor.constraint(equalTo: self.imageUploadButton.widthAnchor),
                        deletableImageView.heightAnchor.constraint(equalTo: self.imageUploadButton.widthAnchor)
                    ])
                }
            }
            .store(in: &bindings)
        
        zip([viewModel.$rockNameValidationResult, viewModel.$rockAddressValidationResult],
            [rockNameErrorLabel, rockAddressErrorLabel])
            .forEach { viewModelResult, label in
            
            viewModelResult.sink { result in
                switch result {
                case .valid, .none:
                    label?.isHidden = true
                    
                case .invalid(let error):
                    label?.text = error.description
                    label?.isHidden = false
                    
                }
            }.store(in: &bindings)
        }
        
        viewModel.$rockLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                
                self.rockRegisterMapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: self.span), animated: true)
                
                self.rockRegisterMapView.removeAnnotations(self.rockRegisterMapView.annotations)
                let rockAddressPin = MKPointAnnotation()
                rockAddressPin.coordinate = location.coordinate
                self.rockRegisterMapView.addAnnotation(rockAddressPin)
            }
            .store(in: &bindings)
        
        viewModel.$rockImageValidationResult
            .receive(on: RunLoop.main)
            .sink { [weak self] hasImage in
                guard let self = self else { return }
                self.rockImageErrorLabel.isHidden = hasImage
                self.rockImageErrorLabel.text = hasImage ? "" : "岩の画像のアップロードは必須です。"
            }
            .store(in: &bindings)
        
        viewModel.$isPassedAllValidation
            .receive(on: RunLoop.main)
            .sink { [weak self] isPassed in
                guard let self = self else { return }
                self.confirmButton.isEnabled = isPassed
            }
            .store(in: &bindings)
    }
    
    private func makeDeletableImageView(data: Data) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.image = UIImage(data: data)
        
        let deleteButton = UIButton(primaryAction: UIAction { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.rockImageDatas.removeAll { $0 == data }
        })
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.AssetsImages.xmarkCircleFill, for: .normal)
        deleteButton.tintColor = .white
        imageView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.topAnchor.constraint(equalTo: imageView.topAnchor),
            deleteButton.rightAnchor.constraint(equalTo: imageView.rightAnchor)
        ])
        return imageView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension RockRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    private func setupKeyboard() {
        UIResponder.keyboardInfoPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] keyboardInfo in
                
                guard let self = self,
                      let firstResponder = self.getFirstResponder(view: self.view) else { return }
                
                let keyboardHeight = keyboardInfo.rect.size.height
                let marginFromResponderToViewBottom = self.view.bounds.height - (firstResponder.frame.origin.y + firstResponder.bounds.height + 8)

                let dupricationHeight = keyboardHeight - marginFromResponderToViewBottom
                
                guard dupricationHeight > 0 else { return }
                
                UIView.animate(withDuration: keyboardInfo.duration) {
                    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: dupricationHeight, right: 0)
                    self.backScrollView.contentInset = contentInsets
                    self.backScrollView.scrollIndicatorInsets = contentInsets
                    self.backScrollView.setContentOffset(.init(x: self.backScrollView.frame.minX, y: marginFromResponderToViewBottom), animated: true)
                }
            }
            .store(in: &bindings)
        
        UIResponder.keyboardHidePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                guard let self = self else { return }

                UIView.animate(withDuration: duration) {
                    self.backScrollView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
                    self.backScrollView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
                }
            }
            .store(in: &bindings)
    }
}

extension RockRegisterViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension RockRegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 1) else { return }
        
        viewModel.rockImageDatas.append(data)
        dismiss(animated: true, completion: nil)
    }
}

extension RockRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.map(\.itemProvider).forEach {
            
            guard $0.canLoadObject(ofClass: UIImage.self) else { return }
            
            $0.loadObject(ofClass: UIImage.self) { [weak self] providerReading, error in
                guard case .none = error,
                      let self = self,
                      let image = providerReading as? UIImage,
                      let data = image.jpegData(compressionQuality: 1) else { return }
                
                self.viewModel.rockImageDatas.append(data)
            }
        }
    }
}
