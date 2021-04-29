//
//  CourseRegisterRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/01.
//

import UIKit

struct CourseRegisterRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = CourseRegisterViewModel

    enum DestinationType: DestinationProtocol {
        case courseConfirm
        case rockDetail
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .courseConfirm:
                pushCourseConfirm(from)

            case .rockDetail:
                dismissToRockDetail(from)

        }
    }

    private func pushCourseConfirm(_ from: UIViewController) {

        guard
            viewModel.callValidations(),
            let header = viewModel.output.header
        else {
            from.showOKAlert(title: "入力内容に不備があります。", message: "入力内容を見直してください。")
            return
        }

        let viewModel = CourseConfirmViewModel(
            rockHeaderStructure: viewModel.registerType.rockHeaderStructure,
            courseName: viewModel.output.courseName,
            grade: viewModel.output.grade,
            shape: viewModel.output.shape,
            header: header,
            images: viewModel.output.images,
            desc: viewModel.output.courseDesc
        )

        from.navigationController?.pushViewController(
            CourseConfirmViewController.createInstance(viewModel: viewModel),
            animated: true
        )
    }

    private func dismissToRockDetail(_ from: UIViewController) {
        from.showAlert(
            title: "編集内容を破棄しますか？",
            actions: [
                .init(title: "破棄", style: .destructive) { _ in
                    from.dismiss(animated: true)
                },
                .init(title: "キャンセル", style: .cancel)
            ],
            style: .actionSheet
        )
    }
}
