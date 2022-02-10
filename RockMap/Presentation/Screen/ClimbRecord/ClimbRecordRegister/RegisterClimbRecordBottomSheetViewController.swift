import Combine
import UIKit

protocol RegisterClimbRecordDetectableDelegate: AnyObject {
    func finishedRegisterClimbed(
        id: String,
        date: Date,
        type: Entity.ClimbRecord.ClimbedRecordType
    )
}

class RegisterClimbRecordBottomSheetViewController: UIViewController {
    @IBOutlet var baseView: UIView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var climbedDatePicker: UIDatePicker!
    @IBOutlet var climbedTypeSegmentedControl: UISegmentedControl!

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
        if
            self.viewModel.isSelectedFutureDate(
                climbedDate: self.viewModel.climbedDate
            )
        {
            showOKAlert(
                title: "未来の日付が入力されています。",
                message: "入力内容をご確認の上、日付を再度選択して下さい。"
            )
            return
        }

        switch self.viewModel.registerType {
        case .create:
            self.viewModel.registerClimbRecord()

        case .edit:
            self.viewModel.editClimbRecord()
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

        self.configureModal()
        self.setupLayout()
        self.setupSegment()
        self.bindViewToViewModel()
        self.bindViewModelToView()

        if case let .edit(climbed) = self.viewModel.registerType {
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
        self.baseView.layer.cornerRadius = 16
        self.recordButton.layer.cornerRadius = 8
        self.climbedTypeSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white as Any],
            for: .selected
        )
        self.climbedDatePicker.layer.borderWidth = 0.5
        self.climbedDatePicker.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupSegment() {
        self.climbedTypeSegmentedControl.removeAllSegments()

        Entity.ClimbRecord.ClimbedRecordType.allCases.enumerated().forEach { index, type in
            climbedTypeSegmentedControl.insertSegment(
                withTitle: type.name,
                at: index, animated: true
            )
        }

        self.climbedTypeSegmentedControl.selectedSegmentIndex = 0
    }

    private func bindViewToViewModel() {
        self.climbedDatePicker
            .datePublisher
            .map { Optional($0) }
            .assign(to: &self.viewModel.$climbedDate)

        self.climbedTypeSegmentedControl
            .selectedSegmentIndexPublisher
            .compactMap { Entity.ClimbRecord.ClimbedRecordType.allCases.any(at: $0) }
            .assign(to: &self.viewModel.$climbRecordType)
    }

    private func bindViewModelToView() {
        self.viewModel.$climbedDate
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] date in

                guard let self = self else { return }

                self.climbedDatePicker.date = date
            }
            .store(in: &self.bindings)

        self.viewModel.$climbRecordType
            .removeDuplicates()
            .map { Entity.ClimbRecord.ClimbedRecordType.allCases.firstIndex(of: $0) }
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] index in

                guard let self = self else { return }

                self.climbedTypeSegmentedControl.selectedSegmentIndex = index
            }
            .store(in: &self.bindings)

        self.viewModel.$loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in

                guard let self = self else { return }

                switch $0 {
                case .standby:
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

                case let .failure(error):
                    self.hideIndicatorView()
                    self.showOKAlert(
                        title: "登録に失敗しました",
                        message: error?.localizedDescription ?? ""
                    )
                }
            }
            .store(in: &self.bindings)
    }
}
