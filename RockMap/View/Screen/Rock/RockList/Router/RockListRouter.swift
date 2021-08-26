//
//  RockListRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/06.
//

import UIKit

struct RocklistRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = RockListViewModel

    enum DestinationType: DestinationProtocol {
        case rockDetail(Entity.Rock)
        case rockRegister(Entity.Rock)
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: DestinationType,
        from context: UIViewController
    ) {
        switch destination {
            case .rockDetail(let rock):
                pushRockDetail(context, rock: rock)

            case .rockRegister(let rock):
                presentCourseRegister(context, rock: rock)

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

        let viewModel = RockDetailViewModel(rock: rockDocument)
        let vc = RockDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentCourseRegister(
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

        let viewModel = RockRegisterViewModel(
            registerType: .edit(rockDocument)
        )
        let vc = RockMapNavigationController(
            rootVC: RockRegisterViewController.createInstance(viewModel: viewModel),
            naviBarClass: RockMapNoShadowNavigationBar.self
        )
        vc.isModalInPresentation = true
        from.present(vc, animated: true)
    }

}
