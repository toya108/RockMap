//
//  MyPageViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import Combine
import UIKit

class MyPageViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var viewModel: MyPageViewModel!
    var router: MyPageRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: MyPageViewModel
    ) -> MyPageViewController {
        let instance = MyPageViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        configureCollectionView()
        configureSections()
        bindViewModelOutput()
    }

    private func setupNavigationBar() {
        navigationItem.title = "マイページ"
        navigationItem.setRightBarButton(
            .init(
                title: nil,
                image: UIImage.SystemImages.gearshapeFill,
                primaryAction: .init { _ in

                },
                menu: nil
            ),
            animated: true
        )
    }

    private func bindViewModelOutput() {
        viewModel.output
            .$headerImageReference
            .receive(on: RunLoop.main)
            .sink { [weak self] reference in

                guard let self = self else { return }

                self.snapShot.reloadSections([.headerImage])
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output
            .$climbedList
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.snapShot.reloadSections([.climbedNumber])
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output
            .$recentClimbedCourses
            .receive(on: RunLoop.main)
            .sink { [weak self] courses in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .recentClimbedCourses))

                if courses.isEmpty {
                    self.snapShot.appendItems([.noCourse], toSection: .recentClimbedCourses)
                } else {
                    self.snapShot.appendItems(
                        courses.map { ItemKind.climbedCourse($0) },
                        toSection: .recentClimbedCourses
                    )
                }
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }

    private func configureSections() {
        snapShot.appendSections(SectionKind.allCases)
        SectionKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        snapShot.appendItems(FIDocument.User.SocialLinkType.allCases.map { ItemKind.socialLink($0) }, toSection: .socialLink)
        datasource.apply(snapShot)
    }
}

extension MyPageViewController {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }

        switch item {
            case .climbedNumber:
                break

            case .climbedCourse(let course):
                router.route(to: .courseDetail(course), from: self)

            case .registeredRock:
                break
            case .registeredCourse:
                break
            default:
                break
        }
    }

}
