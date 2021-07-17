//
//  RegisterClimbedBottomSheetViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/22.
//

import UIKit
import Combine

protocol RegisterClimbRecordDetectableDelegate: AnyObject {
    func finishedRegisterClimbed(
        id: String,
        date: Date,
        type: FIDocument.ClimbRecord.ClimbedRecordType
    )
}

class RegisterClimbRecordBottomSheetViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var climbedDatePicker: UIDatePicker!
    @IBOutlet weak var climbedTypeSegmentedControl: UISegmentedControl!

    weak var delegate: RegisterClimbRecordDetectableDelegate?

    private var viewModel: RegisterClimbRecordViewModel!
    private var bindings = Set<AnyCancellable>()
    
    override func loadView() {
        let nib = UINib(nibName: Self.className, bundle: nil)
        view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    @IBAction func didCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func didRecordButtonTapped(_ sender: UIButton) {

        if viewModel.isSelectedFutureDate(
            climbedDate: viewModel.climbedDate
        ) {
            showOKAlert(
                title: "未来の日付が入力されています。",
                message: "入力内容をご確認の上、日付を再度選択して下さい。"
            )
            return
        }

        switch viewModel.registerType {
            case .create:
                viewModel.registerClimbRecord()

            case .edit:
                viewModel.editClimbRecord()

        }
    }

    static func createInstance(
        viewModel: RegisterClimbRecordViewModel
    ) -> RegisterClimbRecordBottomSheetViewController {
        let instance = RegisterClimbRecordBottomSheetViewController()
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
            viewModel.climbRecordType = climbed.type
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
        
        FIDocument.ClimbRecord.ClimbedRecordType.allCases.enumerated()
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
            .compactMap { FIDocument.ClimbRecord.ClimbedRecordType.allCases.any(at: $0) }
            .assign(to: &viewModel.$climbRecordType)
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

        viewModel.$climbRecordType
            .removeDuplicates()
            .map { FIDocument.ClimbRecord.ClimbedRecordType.allCases.firstIndex(of: $0) }
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] index in

                guard let self = self else { return }

                self.climbedTypeSegmentedControl.selectedSegmentIndex = index
            }
            .store(in: &bindings)

        viewModel.$loadingState
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
                                type: self.viewModel.climbRecordType
                            )
                        }

                    case .failure(let error):
                        self.hideIndicatorView()
                        self.showOKAlert(
                            title: "登録に失敗しました",
                            message: error?.localizedDescription ?? ""
                        )

                }
            }
            .store(in: &bindings)
    }

}

