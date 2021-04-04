//
//  CourseDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import UIKit
import Combine

class CourseDetailViewController: UIViewController {
    
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
        
        setupCollectionView()
//        setupNavigationBar()
        datasource = configureDatasource()
        bindViewToViewModel()
        configureSections()
    }
    
    private func setupCollectionView() {
        collectionView = .init(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
//    private func setupNavigationBar() {
//        guard
//            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
//        else {
//            return
//        }
//
//        rockMapNavigationBar.setup()
//
//        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.prefersLargeTitles = true
//    }
    
    private func bindViewToViewModel() {
        viewModel.$courseImageReference
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] reference in
                
                guard let self = self else { return }

                self.snapShot.appendItems([.headerImage(reference)], toSection: .headerImage)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$courseName
            .receive(on: RunLoop.main)
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                self.navigationItem.title = name
            }
            .store(in: &bindings)
        
        viewModel.$userStructure
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                
                guard let self = self else { return }
                
                if !self.snapShot.itemIdentifiers(inSection: .registeredUser).isEmpty {
                    self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .registeredUser))
                }
                
                self.snapShot.appendItems([.registeredUser(user)], toSection: .registeredUser)
                
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$totalClimbedNumber
            .receive(on: RunLoop.main)
            .sink { [weak self] totalClimbedNumber in

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
        datasource.apply(snapShot)
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
