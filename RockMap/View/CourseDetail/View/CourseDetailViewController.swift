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
        
        configureCollectionView()
        bindViewToViewModel()
        configureSections()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        guard
            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
        else {
            return
        }

        rockMapNavigationBar.setup()
        navigationItem.title = viewModel.course.name
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func bindViewToViewModel() {
        viewModel.output.$fetchCourseHeaderState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchCourseHeaderStateSink)
            .store(in: &bindings)

        viewModel.output.$fetchCourseImageState
            .filter(\.isFinished)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: fetchCourseImageStateSink)
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
        let valueCellData = ValueCollectionViewCell.ValueCellStructure(
            image: UIImage.SystemImages.triangleLefthalfFill,
            title: "岩質",
            subTitle: viewModel.course.shape.map(\.name).joined(separator: "/")
        )
        snapShot.appendItems([.shape(valueCellData)], toSection: .info)
        datasource.apply(snapShot) { [weak self] in
            self?.viewModel.input.finishedCollectionViewSetup.send()
        }
    }
}

extension CourseDetailViewController {

    private func fetchCourseHeaderStateSink(_ state: LoadingState<StorageManager.Reference>) {
        switch state {
            case .stanby, .failure, .loading:
                break

            case .finish:
                snapShot.reloadSections([.headerImage])
                datasource.apply(snapShot, animatingDifferences: false)
        }
    }

    private func fetchCourseImageStateSink(_ state: LoadingState<[StorageManager.Reference]>) {
        switch state {
            case .stanby, .failure, .loading:
                break

            case .finish(let references):
                snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .images))

                if references.isEmpty {
                    snapShot.appendItems([.noImage], toSection: .images)
                } else {
                    snapShot.appendItems(references.map { ItemKind.image($0) }, toSection: .images)
                }
                datasource.apply(snapShot, animatingDifferences: false)
        }
    }

    private func fetchRegisteredUserStateSink(_ state: LoadingState<FIDocument.User>) {
        switch state {
            case .stanby, .failure, .loading:
                break

            case .finish:
                snapShot.reloadSections([.registeredUser])
                datasource.apply(snapShot, animatingDifferences: false)
        }
    }

    private func totalClimbedNumberSink(_ state: FIDocument.TotalClimbedNumber?) {
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
