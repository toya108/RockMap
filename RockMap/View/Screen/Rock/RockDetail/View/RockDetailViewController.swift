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

        configureCollectionView()
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

        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false

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
        courseCreationButton.setImage(UIImage.SystemImages.plusCircleFill, for: .normal)
        courseCreationButton.tintColor = UIColor.Pallete.primaryGreen
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

        viewModel.$rockName
            .receive(on: RunLoop.main)
            .sink { [weak self] title in

                guard let self = self else { return }

                self.snapShot.appendItems([.title("🪨 " + title)], toSection: .title)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$headerImageUrl
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] reference in
                
                guard let self = self else { return }

                self.snapShot.appendItems([.header(reference)], toSection: .header)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.$imageUrls
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
            if dic[grade] == nil {
                dic[grade] = 1
            } else {
                dic[grade]! += 1
            }
        }

        let gradeItem = snapShot.itemIdentifiers(inSection: .info).filter {
            if case .containGrade = $0 {
                return true
            } else {
                return false
            }
        }

        snapShot.deleteItems(gradeItem)
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

extension RockDetailViewController: CourseRegisterDetectableViewControllerProtocol {

    func didCourseRegisterFinished() {
        viewModel.fetchCourses()
    }

}
