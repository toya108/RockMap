//
//  RegisterClimbedBottomSheetViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

import UIKit
import Combine

protocol RegisterClimbedDetectableDelegate: AnyObject {
    func finishedRegisterClimbed(
        id: String,
        date: Date,
        type: FIDocument.Climbed.ClimbedRecordType
    )
}

class RegisterClimbedBottomSheetViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var climbedDatePicker: UIDatePicker!
    @IBOutlet weak var climbedTypeSegmentedControl: UISegmentedControl!

    weak var delegate: RegisterClimbedDetectableDelegate?

    private var viewModel: RegisterClimbedViewModel!
    private var bindings = Set<AnyCancellable>()
    
    override func loadView() {
        let nib = UINib(nibName: Self.className, bundle: nil)
        view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    @IBAction func didCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func didRecordButtonTapped(_ sender: UIButton) {
        switch viewModel.registerType {
            case .create:
                viewModel.registerClimbed()

            case .edit:
                viewModel.editClimbed()

        }
    }

    static func createInstance(
        viewModel: RegisterClimbedViewModel
    ) -> RegisterClimbedBottomSheetViewController {
        let instance = RegisterClimbedBottomSheetViewController()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureModal()
        setupLayout()
        setupSegment()
        bindViewToViewModel()
        bindViewModelToView()

        if case let .edit(climbed) = viewModel.registerType {
            viewModel.climbedDate = climbed.climbedDate
            viewModel.climbedType = climbed.type
        }
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

    private func bindViewToViewModel() {
        climbedDatePicker
            .datePublisher
            .map { Optional($0) }
            .assign(to: &viewModel.$climbedDate)

        climbedTypeSegmentedControl
            .selectedSegmentIndexPublisher
            .compactMap { FIDocument.Climbed.ClimbedRecordType.allCases.any(at: $0) }
            .assign(to: &viewModel.$climbedType)
    }

    private func bindViewModelToView() {
        viewModel.$climbedDate
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] date in

                guard let self = self else { return }

                self.climbedDatePicker.date = date
            }
            .store(in: &bindings)

        viewModel.$climbedType
            .removeDuplicates()
            .map { FIDocument.Climbed.ClimbedRecordType.allCases.firstIndex(of: $0) }
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] index in

                guard let self = self else { return }

                self.climbedTypeSegmentedControl.selectedSegmentIndex = index
            }
            .store(in: &bindings)

        viewModel.$uploadState
            .receive(on: RunLoop.main)
            .sink { [weak self] in

                guard let self = self else { return }

                switch $0 {
                    case .stanby:
                        break

                    case .loading:
                        self.showIndicatorView()

                    case .finish:
                        self.hideIndicatorView()
                        self.dismiss(animated: true)

                        if case let .edit(climbed) = self.viewModel.registerType {
                            self.delegate?.finishedRegisterClimbed(
                                id: climbed.id,
                                date: self.viewModel.climbedDate ?? Date(),
                                type: self.viewModel.climbedType
                            )
                        }

                    case .failure(let error):
                        self.hideIndicatorView()
                        self.showOKAlert(
                            title: "課題登録に失敗しました",
                            message: error?.localizedDescription ?? ""
                        )

                }
            }
            .store(in: &bindings)
    }

}

