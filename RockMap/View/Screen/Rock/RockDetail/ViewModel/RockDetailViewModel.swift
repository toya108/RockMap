//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel: ViewModelProtocol {
    @Published var rockDocument: Entity.Rock
    @Published var rockName = ""
    @Published var rockId = ""
    @Published var registeredUser: Entity.User?
    @Published var rockDesc = ""
    @Published var seasons: Set<Entity.Rock.Season> = []
    @Published var lithology: Entity.Rock.Lithology = .unKnown
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var headerImage: ImageLoadable?
    @Published var images: [ImageLoadable] = []
    @Published var courses: [Entity.Course] = []

    private let fetchUserUsecase = Usecase.User.FetchById()
    private let fetchCoursesUsecase = Usecase.Course.FetchByRockId()

    private var bindings = Set<AnyCancellable>()
    
    init(rock: Entity.Rock) {
        self.rockDocument = rock

        self.rockName = rock.name
        self.rockId = rock.id
        self.rockDesc = rock.desc

        fetchUserUsecase.fetchUser(by: rock.registeredUserId)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map { Optional($0) }
            .assign(to: &$registeredUser)

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
        self.fetchCourses()
    }
    
    func fetchCourses() {
        fetchCoursesUsecase.fetch(by: rockDocument.id)
            .catch { error -> Just<[Entity.Course]> in
                print(error)
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$courses)
    }

    func makeGradeNumberStrings(dic: [Entity.Course.Grade: Int]) -> String {
        dic.map {
            $0.key.name + "/" + $0.value.description + "本"
        }
        .joined(separator: ", ")
    }

}
