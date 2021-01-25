//
//  RockDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/11.
//

import UIKit

class RockDetailViewController: UIViewController {
    @IBOutlet weak var headerScrollView: UIScrollView!
    @IBOutlet weak var headerImageStackView: UIStackView!
    @IBOutlet weak var mainScrollView: HeaderIgnorableScrollView!
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var contentsScrollView: UIScrollView!
    @IBOutlet weak var contentsStackView: UIStackView!
    @IBOutlet weak var contentsStackViewHeight: NSLayoutConstraint!
    
    private var viewModel: RockDetailViewModel!
    
    static func createInstance(viewModel: RockDetailViewModel) -> RockDetailViewController {
        let instance = UIStoryboard.init(
            name: RockDetailViewController.className,
            bundle: nil
        ).instantiateInitialViewController() as? RockDetailViewController
        instance?.viewModel = viewModel
        return instance!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainScrollView.delegate = self
        setupCollectionView()
        contentsStackView.arrangedSubviews.forEach { contentsStackView.removeArrangedSubview($0) }
        RockTabType.allCases.map(\.viewController).forEach {
            addChild($0)
            $0.didMove(toParent: self)
            $0.view.translatesAutoresizingMaskIntoConstraints = false
            contentsStackView.addArrangedSubview($0.view)
            $0.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setup()
    }
    
    private lazy var setup: (() -> Void) = {
        mainScrollView.contentInset.top = headerScrollView.bounds.height
        contentsStackViewHeight.constant = view.bounds.height - tabCollectionView.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        return {}
    }()
    
    private func setupCollectionView() {
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.allowsMultipleSelection = false
        tabCollectionView.register(.init(nibName: TabCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: TabCollectionViewCell.className)
    }
}

extension RockDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= tabCollectionView.frame.minY {
            scrollView.contentOffset.y = tabCollectionView.frame.minY
        }
    }
}

extension RockDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.contentsScrollView.contentOffset = .init(x: self.view.bounds.width * CGFloat(indexPath.row), y: self.contentsScrollView.contentOffset.y)
        }
    }
}

extension RockDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RockTabType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = tabCollectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionViewCell.className, for: indexPath) as? TabCollectionViewCell else { return UICollectionViewCell() }
        cell.setContents(
            title: RockTabType.allCases[indexPath.row].title,
            image: RockTabType.allCases[indexPath.row].image,
            selectingImage: RockTabType.allCases[indexPath.row].selectingImage
        )
        return cell
    }
}

extension RockDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .init(width: collectionView.bounds.width / CGFloat(RockTabType.allCases.count), height: collectionView.bounds.height)
    }
}
