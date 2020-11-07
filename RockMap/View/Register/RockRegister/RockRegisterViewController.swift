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
    @IBOutlet weak var firstImageUploadButton: UIButton!
    @IBOutlet weak var imageSelectHorizontalScrollView: UIScrollView!
    @IBOutlet weak var imageHorizontalStackView: UIStackView!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var rockAddressTextView: UITextView!
    @IBOutlet weak var currentAddressButton: UIButton!
    @IBOutlet weak var mapBaseView: UIView!
    @IBOutlet weak var rockRegisterMapView: MKMapView!
    @IBOutlet weak var rockDescTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    private let viewModel = RockRegisterViewModel()
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupLayout()
        setupKeyboard()
        bindViewToViewModel()
        bindViewModelToView()
        
        rockAddressTextView.text = LocationManager.shared.address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func didFirstImageUploadButtonTapped(_ sender: UIButton) {
        presentImageUploadPopOver(sender: sender)
    }
    
    @IBAction func didImageUploadButtonTapped(_ sender: UIButton) {
        presentImageUploadPopOver(sender: sender)
    }
    
    @IBAction func didCurrentAddressButtonTapped(_ sender: UIButton) {
        rockAddressTextView.text = LocationManager.shared.address
    }
    
    @IBAction func didAddressSelectButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func didConfirmButtonTapped(_ sender: UIButton) {
        
    }
    
    private func setupDelegate() {
        rockNameTextField.delegate = self
    }
    
    private func setupLayout() {
        navigationItem.title = "岩を登録する"
        
        // コード上で指定しないと明朝体になってしまうバグのため
        rockDescTextView.font = UIFont.systemFont(ofSize: 13)
        rockDescTextView.layer.cornerRadius = 8
        rockDescTextView.layer.borderWidth = 1
        rockDescTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        firstImageUploadButton.layer.cornerRadius = 8
        firstImageUploadButton.layer.borderWidth = 1
        firstImageUploadButton.layer.borderColor = UIColor.lightGray.cgColor
        
        currentAddressButton.layer.cornerRadius = 8
        mapBaseView.layer.cornerRadius = 8
        imageUploadButton.layer.cornerRadius = 8
        confirmButton.layer.cornerRadius = 8
    }
    
    private func bindViewToViewModel() {
        rockNameTextField.textDidChangedPublisher.assign(to: &viewModel.$rockName)
        rockAddressTextView.textDidChangedPublisher.assign(to: &viewModel.$rockDesc)
        rockDescTextView.textDidChangedPublisher.assign(to: &viewModel.$rockDesc)
    }
    
    private func bindViewModelToView() {
        viewModel.$rockImageDatas
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                
                guard let self = self else { return }
                
                self.firstImageUploadButton.isHidden = !data.isEmpty
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
    }
    
    private func presentImageUploadPopOver(sender: UIButton) {
        let popOverVC = ImageUploadPopOverTableViewController()
        popOverVC.modalPresentationStyle = .popover
        popOverVC.preferredContentSize = CGSize(width: 300, height: 88)
        popOverVC.popoverPresentationController?.sourceView = sender.superview
        popOverVC.popoverPresentationController?.sourceRect = sender.frame
        popOverVC.popoverPresentationController?.delegate = self
        popOverVC.selectPhotoLibraryCellHandler = selectPhotoLibraryCellHandler
        popOverVC.selectCameraCellHandler = selectCameraCellHandler
        present(popOverVC, animated: true)
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
    
    private var selectCameraCellHandler: () -> Void {{ [weak self] in
        
        guard let self = self else { return }
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .camera
        self.present(vc, animated: true)
    }}
    
    private var selectPhotoLibraryCellHandler: () -> Void {{ [weak self] in
        
        guard let self = self else { return }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }}
    
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
