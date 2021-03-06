//
//  RockDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/02.
//

import UIKit
import Combine

class RockDetailViewController: UIViewController, CollectionViewControllerProtocol {
    
    var collectionView: TouchableColletionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    
    private var viewModel: RockDetailViewModel!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(viewModel: RockDetailViewModel) -> RockDetailViewController {
        let instance = RockDetailViewController()
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        setupCollectionView()
        setupNavigationBar()
        datasource = configureDatasource()
        bindViewToViewModel()
        configureSections()
    }
    
    private func setupCollectionView() {
        setupCollectionView(layout: createLayout())
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
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

        let courseCreationButton = UIButton(
            type: .system,
            primaryAction: .init { [weak self] _ in
                
                guard let self = self else { return }
                
                self.presentCourseRegisterViewController()
            }
        )
        courseCreationButton.setTitle("課題登録", for: .normal)
        courseCreationButton.setImage(UIImage.SystemImages.plusSquare, for: .normal)
        navigationItem.setRightBarButton(
            .init(customView: courseCreationButton),
            animated: false
        )
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        datasource.apply(snapShot)
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
            .receive(on: RunLoop.main)
            .sink { [weak self] desc in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.desc(desc)], toSection: .desc)
                self.datasource.apply(self.snapShot)
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
        
        viewModel.$rockLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] rockLocation in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.map(rockLocation)], toSection: .map)
                self.datasource.apply(self.snapShot)
                
            }
            .store(in: &bindings)
        
        viewModel.$courseIdList
            .receive(on: RunLoop.main)
            .sink { [weak self] idList in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems([.courses, .nocourse])
                
                guard
                    !idList.isEmpty
                else {
                    self.snapShot.appendItems([.nocourse], toSection: .courses)
                    self.datasource.apply(self.snapShot)
                    
                    return
                }
                
                self.snapShot.appendItems([.courses], toSection: .courses)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func presentCourseRegisterViewController() {
        
        guard
            let rockImageReference = self.viewModel.rockImageReferences.first
        else {
            return
        }
        
        let viewModel = CourseRegisterViewModel(
            rockHeaderStructure: .init(
                rockId: self.viewModel.rockDocument.id,
                rockName: self.viewModel.rockName,
                rockImageReference: rockImageReference,
                userIconPhotoURL: self.viewModel.registeredUser.photoURL,
                userName: self.viewModel.registeredUser.name
            )
        )
        
        let vc = RockMapNavigationController(
            rootVC: CourseRegisterViewController.createInstance(viewModel: viewModel),
            naviBarClass: RockMapNavigationBar.self
        )
        vc.isModalInPresentation = true
        present(vc, animated: true)
    }

}
