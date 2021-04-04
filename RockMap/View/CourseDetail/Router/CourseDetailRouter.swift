//
//  CourseDetailRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/03.
//

import UIKit

struct CourseDetailRouter: RouterProtocol {

    typealias Destination = DestinationType

    enum DestinationType: DestinationProtocol {
        case registerClimbed
    }

    private weak var viewModel: CourseDetailViewModel!

    init(viewModel: CourseDetailViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .registerClimbed:
                presentRegisterClimbedBottomSheet(from)

        }
    }

    private func presentRegisterClimbedBottomSheet(_ from: UIViewController) {
        let vc = RegisterClimbedBottomSheetViewController()

        let recodeButtonAction: UIAction = .init { _ in

            guard
                let type = FIDocument.Climbed.ClimbedRecordType.allCases.any(
                    at: vc.climbedTypeSegmentedControl.selectedSegmentIndex
                )
            else {
                return
            }

            vc.showIndicatorView()

            self.viewModel.registerClimbed(
                climbedDate: vc.climbedDatePicker.date,
                type: type
            ) { result in

                defer {
                    vc.hideIndicatorView()
                }

                switch result {
                    case .success:
                        from.dismiss(animated: true)

                    case let .failure:
                        break

                }
            }
        }

        from.present(vc, animated: true) {
            vc.configureRecordButton(recodeButtonAction)
        }
    }

}
