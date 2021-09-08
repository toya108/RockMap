import UIKit

struct RockRegisterRouter: RouterProtocol {
    typealias Destination = DestinationType
    typealias ViewModel = RockRegisterViewModel

    enum DestinationType: DestinationProtocol {
        case rockConfirm
        case rockSearch
        case locationSelect
    }

    weak var viewModel: RockRegisterViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
        case .rockConfirm:
            self.pushRockConfirm(from)

        case .rockSearch:
            self.dismissToRockSearch(from)

        case .locationSelect:
            self.presentLocationSelect(from)
        }
    }

    private func pushRockConfirm(
        _ from: UIViewController
    ) {
        guard
            viewModel.callValidations()
        else {
            from.showOKAlert(title: "入力内容に不備があります。", message: "入力内容を見直してください。")
            return
        }

        let viewModel = RockConfirmViewModel(
            registerType: viewModel.registerType,
            rockEntity: viewModel.rockEntity,
            header: viewModel.output.header,
            images: viewModel.output.images
        )

        from.navigationController?.pushViewController(
            RockConfirmViewController.createInstance(viewModel: viewModel),
            animated: true
        )
    }

    private func dismissToRockSearch(_ from: UIViewController) {
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

    private func presentLocationSelect(
        _ from: UIViewController
    ) {
        guard
            let location = viewModel?.output.rockLocation.location
        else {
            return
        }

        let stroryBoard = UIStoryboard(
            name: RockLocationSelectViewController.className,
            bundle: nil
        )

        let vc = stroryBoard.instantiateInitialViewController { coder in
            RockLocationSelectViewController(
                coder: coder,
                location: location
            )
        }

        guard
            let locationSelectViewController = vc
        else {
            return
        }

        from.present(
            RockMapNavigationController(
                rootVC: locationSelectViewController,
                naviBarClass: RockMapNavigationBar.self
            ),
            animated: true
        )
    }
}
