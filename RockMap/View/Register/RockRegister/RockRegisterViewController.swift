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
    @IBOutlet weak var rockPointTextFiled: UITextField!
    @IBOutlet weak var rockRegisterMapView: MKMapView!
    @IBOutlet weak var rockDescTextView: UITextView!
    
    private let viewModel = RockRegisterViewModel()
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupLayout()
        setupKeyboard()
        bindViewToViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func didFirstImageUploadButtonTapped(_ sender: UIButton) {
        let popOverVC = ImageUploadPopOverTableViewController()
        popOverVC.modalPresentationStyle = .popover
        popOverVC.preferredContentSize = CGSize(width: 300, height: 88)
        popOverVC.popoverPresentationController?.sourceView = backStackView
        popOverVC.popoverPresentationController?.sourceRect = sender.frame
        popOverVC.popoverPresentationController?.delegate = self
        popOverVC.selectPhotoLibraryCellHandler = selectPhotoLibraryCellHandler
        popOverVC.selectCameraCellHandler = selectCameraCellHandler
        present(popOverVC, animated: true)
    }
    
    private func setupDelegate() {
        rockNameTextField.delegate = self
        rockPointTextFiled.delegate = self
    }
    
    private func setupLayout() {
        navigationItem.title = "岩を登録する"

        rockDescTextView.font = UIFont.systemFont(ofSize: 13)
        rockDescTextView.layer.cornerRadius = 8
        rockDescTextView.layer.borderWidth = 1
        rockDescTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        firstImageUploadButton.layer.cornerRadius = 8
        firstImageUploadButton.layer.borderWidth = 1
        firstImageUploadButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func bindViewToViewModel() {
        rockNameTextField.textDidChangedPublisher.assign(to: &viewModel.$rockName)
        rockPointTextFiled.textDidChangedPublisher.assign(to: &viewModel.$rockPoint)
        rockDescTextView.textDidChangedPublisher.assign(to: &viewModel.$rockDesc)
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
                    self.backScrollView.setContentOffset(.init(x: self.backScrollView.frame.minX,
                                                               y: self.view.bounds.height - dupricationHeight - (keyboardHeight + 8)),
                                                         animated: true)
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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
    }
}

extension RockRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            
        
    }
}
