//
//  RegisterClimbedBottomSheetViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

// swiftlint:disable force_cast

import UIKit

class RegisterClimbedBottomSheetViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var climbedDatePicker: UIDatePicker!
    @IBOutlet weak var climbedTypeSegmentedControl: UISegmentedControl!
    
    override func loadView() {
        // MyViewController.xib からインスタンスを生成し root view に設定する
        let nib = UINib(nibName: Self.className, bundle: nil)
        view = nib.instantiate(withOwner: self).first as! UIView
    }
    
    @IBAction func didCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureModal()
        setupLayout()
        setupSegment()
    }
    
    private func configureModal() {
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .formSheet
        isModalInPresentation = false
    }
    
    private func setupLayout() {
        baseView.layer.cornerRadius = 16
        recordButton.layer.cornerRadius = 8
        climbedTypeSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white as Any],
            for: .selected
        )
        climbedDatePicker.layer.borderWidth = 0.5
        climbedDatePicker.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupSegment() {
        
        climbedTypeSegmentedControl.removeAllSegments()
        
        FIDocument.Climbed.ClimbedRecordType.allCases.enumerated()
            .forEach { index, type in
                climbedTypeSegmentedControl.insertSegment(
                    withTitle: type.name,
                    at: index, animated: true
                )
            }
        
        climbedTypeSegmentedControl.selectedSegmentIndex = 0
    }

    func configureRecordButton(_ didTapAction: UIAction) {
        recordButton.addAction(didTapAction, for: .touchUpInside)
    }

}
