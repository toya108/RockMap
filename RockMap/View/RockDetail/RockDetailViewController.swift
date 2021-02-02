//
//  RockDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/11.
//

import UIKit
import Combine

class RockDetailViewController: UIViewController {
    @IBOutlet weak var headerScrollView: UIScrollView!
    @IBOutlet weak var headerImageStackView: UIStackView!
    @IBOutlet weak var mainScrollView: HeaderIgnorableScrollView!
    
    @IBOutlet weak var rockNameLabel: UILabel!
    @IBOutlet weak var registeredUserNameLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var rockDescTextView: UITextView!
    
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var contentsScrollView: UIScrollView!
    @IBOutlet weak var contentsStackView: UIStackView!
    @IBOutlet weak var contentsStackViewHeight: NSLayoutConstraint!
    
    private var viewModel: RockDetailViewModel!
    private var bindings = Set<AnyCancellable>()
    
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
        setupLayout()
        setupCollectionView()
        setupContentsStackView()
        
        bindViewModelToView()
    }
    
    private func bindViewModelToView() {
        viewModel.$rockName
            .map { Optional($0) }
            .receive(on: RunLoop.main)
            .assign(to: \UILabel.text, on: rockNameLabel)
            .store(in: &bindings)
        
        viewModel.$rockName
            .map { Optional($0) }
            .receive(on: RunLoop.main)
            .assign(to: \UINavigationItem.title, on: navigationItem)
            .store(in: &bindings)
        
        viewModel.$rockDesc
            .map { Optional($0) }
            .receive(on: RunLoop.main)
            .assign(to: \UITextView.text, on: rockDescTextView)
            .store(in: &bindings)
        
        viewModel.$registeredUser
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                
                guard let self = self else { return }
                
                self.registeredUserNameLabel.text = user.name
                self.userIconImageView.loadImage(url: user.photoURL)
            }
            .store(in: &bindings)
        
        viewModel.$rockImageReferences
            .receive(on: RunLoop.main)
            .drop(while: { $0.isEmpty })
            .sink { [weak self] references in
                
                guard let self = self else { return }
                
                references.forEach {
                    let imageView = self.makeImageView()
                    imageView.loadImage(reference: $0)
                    self.headerImageStackView.addArrangedSubview(imageView)
                    NSLayoutConstraint.activate([
                        imageView.widthAnchor.constraint(equalToConstant: self.headerImageStackView.bounds.height * 16/9),
                        imageView.heightAnchor.constraint(equalTo: self.headerImageStackView.heightAnchor)
                    ])
                }
                
            }
            .store(in: &bindings)
    }
    
    private func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private func setupLayout() {
        mainScrollView.contentInset.top = headerScrollView.bounds.height
        contentsStackViewHeight.constant =
            view.bounds.height
            - tabCollectionView.bounds.height
            - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        
        userIconImageView.layer.cornerRadius = userIconImageView.bounds.width / 2
        userIconImageView.layer.borderWidth = 1
        userIconImageView.layer.borderColor = UIColor.Pallete.primaryGreen.cgColor
    }
    
    private func setupCollectionView() {
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.allowsMultipleSelection = false
        tabCollectionView.register(
            .init(nibName: TabCollectionViewCell.className, bundle: nil),
            forCellWithReuseIdentifier: TabCollectionViewCell.className
        )
    }
    
    private func setupContentsStackView() {
        contentsStackView.arrangedSubviews.forEach { contentsStackView.removeArrangedSubview($0) }
        
        RockTabType.allCases.map(\.viewController).forEach {
            addChild($0)
            $0.didMove(toParent: self)
            $0.view.translatesAutoresizingMaskIntoConstraints = false
            contentsStackView.addArrangedSubview($0.view)
            $0.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
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
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            
            guard let self = self else { return }
            
            self.contentsScrollView.contentOffset = .init(
                x: self.view.bounds.width * CGFloat(indexPath.row),
                y: self.contentsScrollView.contentOffset.y
            )
        }
    }
}

extension RockDetailViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return RockTabType.allCases.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard
            let cell = tabCollectionView.dequeueReusableCell(
                withReuseIdentifier: TabCollectionViewCell.className,
                for: indexPath
            ) as? TabCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
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
        return .init(
            width: collectionView.bounds.width / CGFloat(RockTabType.allCases.count),
            height: collectionView.bounds.height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}
