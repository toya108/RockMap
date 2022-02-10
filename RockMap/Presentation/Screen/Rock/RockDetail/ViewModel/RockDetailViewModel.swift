import Combine
import Foundation

final class RockDetailViewModel: ViewModelProtocol {
    @Published var rockDocument: Entity.Rock
    @Published var rockName = ""
    @Published var rockId = ""
    @Published var registeredUser: Entity.User?
    @Published var rockDesc = ""
    @Published var seasons: [Entity.Rock.Season] = []
    @Published var lithology: Entity.Rock.Lithology = .unKnown
    @Published var area: String = ""
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var headerImage: URL?
    @Published var images: [URL] = []
    @Published var courses: [Entity.Course] = []

    private let fetchUserUsecase = Usecase.User.FetchById()
    private let fetchCoursesUsecase = Usecase.Course.FetchByRockId()

    private var bindings = Set<AnyCancellable>()

    init(rock: Entity.Rock) {
        self.rockDocument = rock

        self.rockName = rock.name
        self.rockId = rock.id
        self.rockDesc = rock.desc

        Task {
            do {
                let user = try await self.fetchUserUsecase.fetchUser(by: rock.registeredUserId)
                self.registeredUser = user
            } catch {
                print(error)
            }
        }

        self.rockLocation = .init(
            location: .init(
                latitude: rock.location.latitude,
                longitude: rock.location.longitude
            ),
            address: rock.address,
            prefecture: rock.prefecture
        )
        self.seasons = rock.seasons
        self.lithology = rock.lithology
        self.area = rock.area ?? "未登録"
        self.headerImage = rock.headerUrl
        self.images = rock.imageUrls
        self.fetchCourses()
    }

    func fetchCourses() {
        Task {
            do {
                let courses = try await self.fetchCoursesUsecase.fetch(by: self.rockDocument.id)
                self.courses = courses.sorted { $0.createdAt > $1.createdAt }
            } catch {
                print(error)
            }
        }
    }

    func makeGradeNumberStrings(dic: [Entity.Course.Grade: Int]) -> String {
        dic.map {
            $0.key.name + "/" + $0.value.description + "本"
        }
        .joined(separator: ", ")
    }
}
