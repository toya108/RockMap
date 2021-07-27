//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel: ViewModelProtocol {
    @Published var rockDocument: FIDocument.Rock
    @Published var rockName = ""
    @Published var rockId = ""
    @Published var registeredUser: FIDocument.User?
    @Published var rockDesc = ""
    @Published var seasons: Set<FIDocument.Rock.Season> = []
    @Published var lithology: FIDocument.Rock.Lithology = .unKnown
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var headerImageUrl: URL?
    @Published var imageUrls: [URL] = []
    @Published var courses: [FIDocument.Course] = []

    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rock) {
        self.rockDocument = rock

        self.rockName = rock.name
        self.rockId = rock.id
        self.rockDesc = rock.desc
        self.headerImageUrl = rock.headerUrl
        self.imageUrls = rock.imageUrls

        FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(rock.registeredUserId)
            .getDocument(FIDocument.User.self)
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
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
        FirestoreManager.db
            .collectionGroup(FIDocument.Course.colletionName)
            .whereField("parentRockId", in: [rockDocument.id])
            .getDocuments(FIDocument.Course.self)
            .catch { error -> Just<[FIDocument.Course]> in
                print(error)
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$courses)
    }

}
