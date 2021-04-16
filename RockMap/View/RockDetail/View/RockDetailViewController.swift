//
//  RockDetailViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/02.
//

import UIKit
import Combine
import MapKit

class RockDetailViewController: UIViewController, CompositionalColectionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

    var router: RockDetailRouter!
    var viewModel: RockDetailViewModel!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(viewModel: RockDetailViewModel) -> RockDetailViewController {
        let instance = RockDetailViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupNavigationBar()
        bindViewToViewModel()
        configureSections()
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
                
                self.router.route(
                    to: .courseRegister,
                    from: self
                )
            }
        )
        courseCreationButton.setTitle("課題登録", for: .normal)
        courseCreationButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        courseCreationButton.setImage(UIImage.SystemImages.plusCircle, for: .normal)
        courseCreationButton.setTitleColor(UIColor.Pallete.primaryGreen, for: .normal)
        courseCreationButton.tintColor = UIColor.Pallete.primaryGreen
        navigationItem.setRightBarButton(
            .init(customView: courseCreationButton),
            animated: false
        )
    }

    private func setupCollectionView() {
        configureCollectionView()
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
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
        
        viewModel.$headerImageReference
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] reference in
                
                guard let self = self else { return }

                self.snapShot.appendItems([.header(reference)], toSection: .header)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$imageReferences
            .receive(on: RunLoop.main)
            .sink { [weak self] references in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))

                if references.isEmpty {
                    self.snapShot.appendItems([.noImage], toSection: .images)
                } else {
                    self.snapShot.appendItems(references.map { ItemKind.image($0) }, toSection: .images)
                }

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
        
        viewModel.$seasons
            .receive(on: RunLoop.main)
            .sink { [weak self] seasons in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.season(seasons)], toSection: .info)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$lithology
            .receive(on: RunLoop.main)
            .sink { [weak self] lithology in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.lithology(lithology)], toSection: .info)
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
                
                self.handleGrades(courses.map(\.grade))
                self.handleCourses(courses)
            }
            .store(in: &bindings)
    }

    private func handleGrades(_ grades: [FIDocument.Course.Grade]) {

        if grades.isEmpty { return }

        let gadesCounts = grades.reduce(into: [FIDocument.Course.Grade: Int]()) { dic, grade in
            dic[grade] = dic[grade] ?? 0 + 1
        }
        snapShot.appendItems([.containGrade(gadesCounts)], toSection: .info)
        datasource.apply(snapShot)
    }

    private func handleCourses(_ courses: [FIDocument.Course]) {
        snapShot.deleteItems(snapShot.itemIdentifiers(inSection: .courses))

        if courses.isEmpty {
            snapShot.appendItems([.nocourse], toSection: .courses)
        } else {
            snapShot.appendItems(courses.map { ItemKind.courses($0) }, toSection: .courses)
        }
        datasource.apply(snapShot)
    }
    
    func updateCouses() {
        viewModel.fetchCourses()
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

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        guard
            let item = datasource.itemIdentifier(for: indexPath)
        else {
            return
        }
        
        switch item {
        case let .courses(course):
            collectionView.cellForItem(at: indexPath)?.executeSelectAnimation()
            router.route(
                to: .courseDetail(course),
                from: self
            )
            
        default:
            break
            
        }
    }

}
