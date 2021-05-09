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

    static func createInstance(viewModel: CourseDetailViewModel) -> CourseDetailViewController {
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
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                
                guard let self = self else { return }

                self.snapShot.reloadSections([.headerImage])
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output.$fetchCourseImageState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in

                guard let self = self else { return }

                switch state {
                    case .stanby, .failure, .loading:
                        break

                    case .finish(let references):
                        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))

                        if references.isEmpty {
                            self.snapShot.appendItems([.noImage], toSection: .images)
                        } else {
                            self.snapShot.appendItems(references.map { ItemKind.image($0) }, toSection: .images)
                        }
                        self.datasource.apply(self.snapShot)
                }
            }
            .store(in: &bindings)

        viewModel.output.$fetchRegisteredUserState
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.snapShot.reloadSections([.registeredUser])

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output.$totalClimbedNumber
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.snapShot.reloadItems(self.snapShot.itemIdentifiers(inSection: .climbedNumber))

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }

    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        datasource.apply(snapShot) { [weak self] in
            self?.viewModel.input.finishedCollectionViewSetup.send()
        }
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
