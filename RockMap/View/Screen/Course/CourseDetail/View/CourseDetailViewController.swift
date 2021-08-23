//
//  CourseDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit
import Combine

class CourseDetailViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    var viewModel: CourseDetailViewModel!
    var router: CourseDetailRouter!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseDetailViewModel
    ) -> CourseDetailViewController {
        let instance = CourseDetailViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        configureCollectionView()
        bindViewToViewModel()
        configureSections()
    }
    
    private func setupNavigationBar() {
        guard
            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
        else {
            return
        }

        rockMapNavigationBar.setup()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func bindViewToViewModel() {
        viewModel.output.$fetchParentRockState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchParentRockStateSink)
            .store(in: &bindings)

        viewModel.output.$fetchRegisteredUserState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchRegisteredUserStateSink)
            .store(in: &bindings)

        viewModel.output.$totalClimbedNumber
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: totalClimbedNumberSink)
            .store(in: &bindings)
    }

    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        if let url = viewModel.course.headerUrl {
            snapShot.appendItems([.headerImage(url)], toSection: .headerImage)
        }
        let valueCellData = ValueCollectionViewCell.ValueCellStructure(
            image: UIImage.SystemImages.triangleLefthalfFill,
            title: "形状",
            subTitle: viewModel.course.shape.map(\.name).joined(separator: "/")
        )
        snapShot.appendItems([.shape(valueCellData)], toSection: .info)

        let images = viewModel.course.imageUrls
        if images.isEmpty {
            snapShot.appendItems([.noImage], toSection: .images)
        } else {
            snapShot.appendItems(images.map { ItemKind.image($0) }, toSection: .images)
        }
        datasource.apply(snapShot) { [weak self] in
            self?.viewModel.input.finishedCollectionViewSetup.send()
        }
    }
}

extension CourseDetailViewController {

    private func fetchParentRockStateSink(_ state: LoadingState<FIDocument.Rock>) {
        switch state {
            case .stanby, .failure, .loading:
                break

            case .finish:
                snapShot.deleteItems([.parentRock])
                snapShot.appendItems([.parentRock], toSection: .parentRock)
                datasource.apply(snapShot, animatingDifferences: false)
        }
    }
    
    private func fetchRegisteredUserStateSink(_ state: LoadingState<Entity.User>) {
        switch state {
            case .stanby, .failure, .loading:
                break

            case .finish:
                snapShot.deleteItems([.registeredUser])
                snapShot.appendItems([.registeredUser], toSection: .registeredUser)
                datasource.apply(snapShot, animatingDifferences: false)
        }
    }

    private func totalClimbedNumberSink(_ state: Entity.TotalClimbedNumber?) {
        snapShot.reloadSections([.climbedNumber])
        datasource.apply(snapShot, animatingDifferences: false)
    }

}

extension CourseDetailViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = datasource.itemIdentifier(for: indexPath)

        switch item {
            case .climbedNumber:
                router.route(to: .climbedUserList, from: self)

            default:
                break
        }
    }
}
