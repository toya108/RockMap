
import Auth
import UIKit
import CoreLocation

struct RockSeachRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockSearchViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(Entity.Rock)
        case rockRegister(CLLocation)
    }

    internal weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case let .rockDetail(rock):
                pushRockDetail(from, rock: rock)

            case let .rockRegister(location):
                presentRockRegister(
                    from,
                    location: location
                )

        }
    }

    private func pushRockDetail(
        _ from: UIViewController,
        rock: Entity.Rock
    ) {

        let rockDocument = FIDocument.Rock(
            id: rock.id,
            createdAt: rock.createdAt,
            updatedAt: rock.updatedAt,
            parentPath: rock.parentPath,
            name: rock.name,
            address: rock.address,
            prefecture: rock.prefecture,
            location: .init(latitude: rock.location.latitude, longitude: rock.location.longitude),
            seasons: Set(rock.seasons.compactMap { .init(rawValue: $0.rawValue) }),
            lithology: .init(rawValue: rock.lithology.rawValue) ?? .unKnown,
            desc: rock.desc,
            registeredUserId: rock.registeredUserId,
            headerUrl: rock.headerUrl,
            imageUrls: rock.imageUrls
        )

        let rockDetailViewModel = RockDetailViewModel(rock: rockDocument)
        from.navigationController?.pushViewController(
            RockDetailViewController.createInstance(viewModel: rockDetailViewModel),
            animated: true
        )
    }

    private func presentRockRegister(
        _ from: UIViewController,
        location: CLLocation
    ) {
        guard
            AuthManager.shared.isLoggedIn
        else {
            from.showNeedsLoginAlert(message: "岩情報を登録するにはログインが必要です。ログインして登録を続けますか？")
            return
        }

        let rockRegisterViewModel = RockRegisterViewModel(registerType: .create(location))
        let registerVc = RockRegisterViewController.createInstance(viewModel: rockRegisterViewModel)
        let vc = RockMapNavigationController(
            rootVC: registerVc,
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        vc.isModalInPresentation = true

        from.present(vc, animated: true)
    }
}
