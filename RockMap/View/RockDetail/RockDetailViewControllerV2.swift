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
        case overview
        case cources
        case map
        
        var sectionIndex: Int {
            switch self {
            case .headerImages: return 0
            case .overview: return 1
            case .cources: return 2
            case .map: return 3
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            HorizontalImageListCollectionViewCell.self,
            forCellWithReuseIdentifier: HorizontalImageListCollectionViewCell.className
        )
        collectionView.register(
            .init(
                nibName: RockOverviewCollectionViewCell.className,
                bundle: nil
            ),
            forCellWithReuseIdentifier: RockOverviewCollectionViewCell.className
        )
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
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(200)
                    ),
                    subitems: [item]
                )
                group.contentInsets.bottom = 8
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging
                return section
            case .overview:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(300)
                    ),
                    subitems: [item]
                )
                
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

}

extension RockDetailViewControllerV2: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let sectionType = SectionLayoutKind.allCases[indexPath.section]
        
        switch sectionType {
        case .headerImages:
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HorizontalImageListCollectionViewCell.className,
                    for: indexPath
                ) as? HorizontalImageListCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.imageView.image = UIImage.AssetsImages.rock
            cell.backgroundColor = UIColor.Pallete.primaryGreen
            return cell
            
        case .overview:
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RockOverviewCollectionViewCell.className,
                    for: indexPath
                ) as? RockOverviewCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            cell.backgroundColor = .blue
            cell.userIconImageView.image = UIImage.AssetsImages.pencilCircle
            cell.userNameLabel.text = "hoge"
            return cell
            
        default:
            return UICollectionViewCell()
            
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        let sectionType = SectionLayoutKind.allCases[section]
        
        switch sectionType {
        case .headerImages:
            return 3
            
        case .overview:
            return 1
            
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionLayoutKind.allCases.count
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
