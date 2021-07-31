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
    @Published var headerImage: ImageLoadable?
    @Published var images: [ImageLoadable] = []
    @Published var courses: [FIDocument.Course] = []

    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rock) {
        self.rockDocument = rock

        self.rockName = rock.name
        self.rockId = rock.id
        self.rockDesc = rock.desc
        setImage(rock: rock)

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

    private func setImage(rock: FIDocument.Rock) {
        setHeaderStorage(rock: rock)
        setStorages(rock: rock)
    }

    private func setHeaderStorage(rock: FIDocument.Rock) {

        if let headerUrl = rock.headerUrl {
            self.headerImage = .url(headerUrl)
            return
        }

        StorageManager.getReference(
            destinationDocument: FINameSpace.Rocks.self,
            documentId: rock.id,
            imageType: .header
        )
        .catch { error -> Empty in
            print(error.localizedDescription)
            return Empty()
        }
        .compactMap { $0 }
        .map { ImageLoadable.storage($0) }
        .assign(to: &$headerImage)
    }

    private func setStorages(rock: FIDocument.Rock) {

        guard rock.imageUrls.isEmpty else {
            self.images = rock.imageUrls.map { .url($0) }
            return
        }

        StorageManager
            .getNormalImagePrefixes(
                destinationDocument: FINameSpace.Rocks.self,
                documentId: rock.id
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .flatMap {
                $0.getReferences().catch { error -> Empty in
                    print(error)
                    return Empty()
                }
            }
            .map {
                $0.map { ImageLoadable.storage($0) }
            }
            .assign(to: &$images)
    }

}
