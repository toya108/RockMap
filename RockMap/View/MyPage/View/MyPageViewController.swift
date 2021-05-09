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

        collectionView.refreshControl?.addAction(
            .init { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.fetchUser()
            },
            for: .valueChanged
        )
    }

    private func setupNavigationBar() {
        navigationItem.title = "マイページ"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
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
        viewModel.output.$fetchUserState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: userSink)
            .store(in: &bindings)

        viewModel.output
            .$headerImageReference
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: headerImageReferenceSink)
            .store(in: &bindings)

        viewModel.output
            .$climbedList
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: climbedListSink)
            .store(in: &bindings)

        viewModel.output
            .$recentClimbedCourses
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: recentClimbedCoursesSink)
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

    private func userSink(_ user: LoadingState<FIDocument.User>) {
        snapShot.reloadItems(snapShot.itemIdentifiers(inSection: .user))
        datasource.apply(snapShot)
    }

    private func headerImageReferenceSink(_ header: StorageManager.Reference) {
        snapShot.reloadSections([.headerImage])
        datasource.apply(snapShot)
    }

    private func climbedListSink(_ climbedList: Set<FIDocument.Climbed>) {
        self.snapShot.reloadSections([.climbedNumber])
        self.datasource.apply(self.snapShot)
    }

    private func recentClimbedCoursesSink(_ courses: Set<FIDocument.Course>) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .recentClimbedCourses))

        if courses.isEmpty {
            snapShot.appendItems([.noCourse], toSection: .recentClimbedCourses)
        } else {
            snapShot.appendItems(
                courses.map { ItemKind.climbedCourse($0) },
                toSection: .recentClimbedCourses
            )
        }
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
                router.route(
                    to: .rockList(AuthManager.shared.authUserReference),
                    from: self
                )

            case .registeredCourse:
                router.route(
                    to: .courseList(AuthManager.shared.authUserReference),
                    from: self
                )

            default:
                break
        }
    }

}
