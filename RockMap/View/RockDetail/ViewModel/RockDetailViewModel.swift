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
    @Published var headerImageReference: StorageManager.Reference?
    @Published var imageReferences: [StorageManager.Reference] = []
    @Published var courses: [FIDocument.Course] = []

    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rock) {
        self.rockDocument = rock

        setupBindings()
        
        self.rockName = rock.name
        self.rockId = rock.id
        self.rockDesc = rock.desc

        FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(rock.registedUserId)
            .getDocument(FIDocument.User.self)
            .catch { _ -> Just<FIDocument.User?> in
                return .init(nil)
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
    
    private func setupBindings() {
        $rockId
            .drop(while: \.isEmpty)
            .flatMap {
                StorageManager.getHeaderReference(
                    destinationDocument: FINameSpace.Rocks.self,
                    documentId: $0
                )
            }
            .catch { _ -> Just<StorageManager.Reference?> in
                return .init(nil)
            }
            .assign(to: &$headerImageReference)

        $rockId
            .drop(while: \.isEmpty)
            .flatMap {
                StorageManager.getNormalImagePrefixes(
                    destinationDocument: FINameSpace.Rocks.self,
                    documentId: $0
                )
                .catch { _ -> Just<[StorageManager.Reference]> in
                    return .init([])
                }
            }
            .sink { prefixes in
                prefixes
                    .map { $0.getReferences() }
                    .forEach {
                        $0.catch { _ -> Just<[StorageManager.Reference]> in
                            return .init([])
                        }
                        .sink { [weak self] references in

                            guard let self = self else { return }

                            self.imageReferences.append(contentsOf: references)
                        }
                        .store(in: &self.bindings)
                    }
            }
            .store(in: &bindings)
    }
    
    func fetchCourses() {
        FirestoreManager.db
            .collectionGroup(FIDocument.Course.colletionName)
            .whereField("parentRockId", in: [rockDocument.id])
            .getDocuments(FIDocument.Course.self)
            .catch { _ -> Just<[FIDocument.Course]> in
                return .init([])
            }
            .map { $0.sorted { $0.createdAt > $1.createdAt } }
            .assign(to: &$courses)
    }

}
