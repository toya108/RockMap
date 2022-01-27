import Combine
import MapKit
import UIKit

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

        configureDefaultConfiguration()
        self.setupNavigationBar()
        self.bindViewToViewModel()
        self.configureSections()
        self.setupNotification()
    }

    private func setupNavigationBar() {
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
        self.snapShot.appendSections(SectionLayoutKind.allCases)
        self.datasource.apply(self.snapShot)
    }

    private func setupNotification() {
        NotificationCenter.default.publisher(for: .didCourseRegisterFinished)
            .sink { [weak self] _ in

                guard let self = self else { return }

                self.viewModel.fetchCourses()
            }
            .store(in: &bindings)
    }

    private func bindViewToViewModel() {
        self.viewModel.$rockName
            .receive(on: RunLoop.main)
            .sink { [weak self] title in

                guard let self = self else { return }

                self.snapShot.appendItems([.title(title)], toSection: .title)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$headerImage
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink { [weak self] loadable in

                guard let self = self else { return }

                self.snapShot.appendItems([.header(loadable)], toSection: .header)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$images
            .receive(on: RunLoop.main)
            .sink { [weak self] loadables in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))

                if loadables.isEmpty {
                    self.snapShot.appendItems([.noImage], toSection: .images)
                } else {
                    self.snapShot.appendItems(
                        loadables.map { ItemKind.image($0) },
                        toSection: .images
                    )
                }

                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$rockDesc
            .receive(on: RunLoop.main)
            .sink { [weak self] desc in

                guard let self = self else { return }

                self.snapShot.appendItems([.desc(desc)], toSection: .desc)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$seasons
            .receive(on: RunLoop.main)
            .sink { [weak self] seasons in

                guard let self = self else { return }

                self.snapShot.appendItems([.season(seasons)], toSection: .info)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$lithology
            .receive(on: RunLoop.main)
            .sink { [weak self] lithology in

                guard let self = self else { return }

                self.snapShot.appendItems([.lithology(lithology)], toSection: .info)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$area
            .receive(on: RunLoop.main)
            .sink { [weak self] area in

                guard let self = self else { return }

                self.snapShot.appendItems([.area(area)], toSection: .info)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$registeredUser
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
            .store(in: &self.bindings)

        self.viewModel.$rockLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] rockLocation in

                guard let self = self else { return }

                self.snapShot.appendItems([.map(rockLocation)], toSection: .map)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &self.bindings)

        self.viewModel.$courses
            .receive(on: RunLoop.main)
            .sink { [weak self] courses in

                guard let self = self else { return }

                self.handleGrades(courses.map(\.grade))
                self.handleCourses(courses)
            }
            .store(in: &self.bindings)
    }

    private func handleGrades(_ grades: [Entity.Course.Grade]) {
        if grades.isEmpty { return }

        let gadesCounts = grades.reduce(into: [Entity.Course.Grade: Int]()) { dic, grade in
            if dic[grade] == nil {
                dic[grade] = 1
            } else {
                dic[grade]! += 1
            }
        }

        let gradeItem = self.snapShot.itemIdentifiers(inSection: .info).filter {
            if case .containGrade = $0 {
                return true
            } else {
                return false
            }
        }

        self.snapShot.deleteItems(gradeItem)
        self.snapShot.appendItems([.containGrade(gadesCounts)], toSection: .info)
        self.datasource.apply(self.snapShot)
    }

    private func handleCourses(_ courses: [Entity.Course]) {
        self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .courses))

        if courses.isEmpty {
            self.snapShot.appendItems([.nocourse], toSection: .courses)
        } else {
            self.snapShot.appendItems(courses.map { ItemKind.courses($0) }, toSection: .courses)
        }
        self.datasource.apply(self.snapShot)
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
            self.router.route(
                to: .courseDetail(course),
                from: self
            )

        default:
            break
        }
    }
}
