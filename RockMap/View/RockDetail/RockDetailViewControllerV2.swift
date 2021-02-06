//
//  RockDetailViewControllerV2.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/02.
//

import UIKit
import Combine
import SwiftUI

class RockDetailViewControllerV2: UIViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case headerImages
        case registeredUser
        case cources
        case map
    }
    
    enum ItemKind: Hashable {
        case headerImages(referece: StorageManager.Reference)
        case registeredUser(user: FIDocument.Users)
        case cources
        case map
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.createLayout()
        )
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    
    private var viewModel: RockDetailViewModel!
    private var bindings = Set<AnyCancellable>()
    
    static func createInstance(viewModel: RockDetailViewModel) -> RockDetailViewControllerV2 {
        let instance = UIStoryboard.init(
            name: RockDetailViewControllerV2.className,
            bundle: nil
        ).instantiateInitialViewController() as? RockDetailViewControllerV2
        instance?.viewModel = viewModel
        return instance!
    }
    
    private var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    
    private lazy var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> = {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                
                guard let self = self else { return UICollectionViewCell() }
                
                switch item {
                case let .headerImages(referece):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureHeaderImageCell(),
                        for: indexPath,
                        item: referece
                    )

                case .registeredUser(user: let user):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRegisteredUserCell(),
                        for: indexPath,
                        item: user
                    )
                case .cources:
                    return UICollectionViewCell()
                    
                case .map:
                    return UICollectionViewCell()
                    
                }
            }
        )
        return datasource
    }()
    
    private func configureHeaderImageCell() -> UICollectionView.CellRegistration<
        HorizontalImageListCollectionViewCell,
        StorageManager.Reference
    > {
        UICollectionView.CellRegistration<
            HorizontalImageListCollectionViewCell,
            StorageManager.Reference
        > { cell, _, reference in
            cell.imageView.loadImage(reference: reference)
        }
    }
    
    private func configureRegisteredUserCell() -> UICollectionView.CellRegistration<
        RegisteredUserCollectionViewCell,
        FIDocument.Users
    > {
        UICollectionView.CellRegistration<
            RegisteredUserCollectionViewCell,
            FIDocument.Users
        >(
            cellNib: .init(
                nibName: RegisteredUserCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, user in
            cell.userNameLabel.text = user.name
            cell.userIconImageView.loadImage(url: user.photoURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupColletionView()
        setupNavigationBar()
        bindViewToViewModel()
        
        snapShot.appendSections(SectionLayoutKind.allCases)
        datasource.apply(snapShot)
    }
    
    private func setupNavigationBar() {
        guard
            let rockMapNavigationBar = navigationController?.navigationBar as? RockMapNavigationBar
        else {
            return
        }
        
        rockMapNavigationBar.setup()

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupColletionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    static private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {
            sectionNumber, env -> NSCollectionLayoutSection in
            
            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            
            switch sectionType {
            case .headerImages:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let height = UIScreen.main.bounds.width * 9/16
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    ),
                    subitems: [item]
                )
                group.contentInsets.bottom = 8
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                return section
                
            case .registeredUser:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(48)
                    ),
                    subitems: [item]
                )
                group.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                let section = NSCollectionLayoutSection(group: group)
                return section
                
            case .cources:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitems: [item]
                )
                group.contentInsets.bottom = 8
                group.contentInsets.leading = 8
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                return section
                
            case .map:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitems: [item]
                )
                group.contentInsets.bottom = 8
                group.contentInsets.leading = 8
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                return section
            }
            
        }
    }
    
    private func bindViewToViewModel() {
        viewModel.$rockName
            .map { Optional($0) }
            .receive(on: RunLoop.main)
            .assign(to: \UINavigationItem.title, on: navigationItem)
            .store(in: &bindings)
        
        viewModel.$rockImageReferences
            .receive(on: RunLoop.main)
            .sink { [weak self] references in
                
                guard let self = self else { return }
                if references.isEmpty { return }
                
                let items = references.map { ItemKind.headerImages(referece: $0) }
                self.snapShot.appendItems(items, toSection: .headerImages)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$rockDesc
            .map { Optional($0) }
            .receive(on: RunLoop.main)
            .sink { [weak self] desc in
                
                guard let self = self else { return }
                
                
            }
            .store(in: &bindings)
        
        viewModel.$registeredUser
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] user in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.registeredUser(user: user)], toSection: .registeredUser)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Container().edgesIgnoringSafeArea(.all)
    }
    
    struct Container: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> RockDetailViewControllerV2 {
            RockDetailViewControllerV2.createInstance(viewModel: .init(rock: .init()))
        }
        
        func updateUIViewController(_ uiViewController: RockDetailViewControllerV2, context: Context) {
            
        }
        
        typealias UIViewControllerType = RockDetailViewControllerV2
    }
}

struct ContentView: View {
    var body: some View {
        Text("aaaa")
    }
}
