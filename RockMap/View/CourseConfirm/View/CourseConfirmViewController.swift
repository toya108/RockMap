//
//  CourseConfirmViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/25.
//

import Combine
import UIKit

class CourseConfirmViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var viewModel: CourseConfirmViewModel!
    var router: CourseConfirmRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: CourseConfirmViewModel
    ) -> CourseConfirmViewController {
        let instance = CourseConfirmViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        setupNavigationBar()
        bindViewModelToView()
        configureSections()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "登録内容を確認"
    }
    
    private func bindViewModelToView() {
        viewModel.output.$imageUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: imageUploadStateSink)
            .store(in: &bindings)
        
        viewModel.output.$courseUploadState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: courseUploadStateSink)
            .store(in: &bindings)
    }
    
    private func configureSections() {
        if case let .create(rockHeader) = viewModel.registerType {
            snapShot.appendSections([.rock])
            snapShot.appendItems([.rock(rockHeader)], toSection: .rock)
        }
        snapShot.appendSections(SectionLayoutKind.allCases.filter { $0 != .rock })
        snapShot.appendItems([.courseName(viewModel.courseDocument.name)], toSection: .courseName)
        snapShot.appendItems([.desc(viewModel.courseDocument.desc)], toSection: .desc)
        snapShot.appendItems([.grade(viewModel.courseDocument.grade)], toSection: .grade)
        snapShot.appendItems([.shape(viewModel.courseDocument.shape)], toSection: .shape)
        snapShot.appendItems([.header(viewModel.header)], toSection: .header)
        snapShot.appendItems(
            viewModel.images.filter(\.shouldAppendItem).map { ItemKind.images($0) },
            toSection: .images
        )
        snapShot.appendItems([.register], toSection: .register)
        datasource.apply(snapShot)
    }
}

extension CourseConfirmViewController {

    private func imageUploadStateSink(_ state: StorageUploader.UploadState) {
        switch state {
            case .stanby:
                hideIndicatorView()

            case .progress:
                showIndicatorView()

            case .complete:
                hideIndicatorView()
                viewModel.input.registerCourseSubject.send()

            case .failure(let error):
                hideIndicatorView()
                showOKAlert(
                    title: "画像の登録に失敗しました",
                    message: error.localizedDescription
                )
        }
    }

    private func courseUploadStateSink(_ state: LoadingState<Void>) {
        switch state {
            case .stanby:
                break

            case .loading:
                showIndicatorView()

            case .finish:
                hideIndicatorView()
                router.route(to: .dismiss, from: self)

            case .failure(let error):
                showOKAlert(
                    title: "岩の登録に失敗しました",
                    message: error?.localizedDescription ?? ""
                )
        }
    }

}

extension CourseConfirmViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}
