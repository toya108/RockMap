//
//  RockDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/02.
//

import UIKit
import Combine
import MapKit

class RockDetailViewController: UIViewController {
    
    var collectionView: UICollectionView!
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
        collectionView = .init(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        collectionView.delegate = self
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
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
        courseCreationButton.setImage(UIImage.SystemImages.plusCircle, for: .normal)
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
                
                guard
                    let self = self,
                    let user = user
                else {
                    return
                }
                
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
        
        viewModel.$courses
            .receive(on: RunLoop.main)
            .sink { [weak self] courses in
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .courses))
                
                if courses.isEmpty {
                    self.snapShot.appendItems([.nocourse], toSection: .courses)
                } else {
                    self.snapShot.appendItems(courses.map { ItemKind.courses($0) }, toSection: .courses)
                }
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    func presentCourseRegisterViewController() {
        
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
                uid: self.viewModel.registeredUser?.id ?? "",
                userIconPhotoURL: self.viewModel.registeredUser?.photoURL,
                userName: self.viewModel.registeredUser?.name ?? ""
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

extension RockDetailViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            return nil
        }
        
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        )
        
        guard
            let markerAnnotationView = annotationView as? MKMarkerAnnotationView
        else {
            return annotationView
        }

        markerAnnotationView.markerTintColor = UIColor.Pallete.primaryGreen
        return markerAnnotationView
    }
}

extension RockDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        switch item {
        case let .courses(course):
            collectionView.cellForItem(at: indexPath)?.executeSelectAnimation()
            
            
        default:
            break
            
        }
    }
}
