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
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in
            
            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets.bottom = 16
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(200)
                ),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            return section
        }
    }
}

extension RockDetailViewControllerV2: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.Pallete.primaryGreen
        return cell
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
