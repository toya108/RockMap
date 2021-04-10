//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel {
    @Published var rockDocument: FIDocument.Rock
    @Published var rockName = ""
    @Published var registeredUser: FIDocument.User?
    @Published var rockDesc = ""
    @Published var seasons: Set<FIDocument.Rock.Season> = []
    @Published var lithology: FIDocument.Rock.Lithology = .unKnown
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var headerImageReference: StorageManager.Reference?
    @Published var courses: [FIDocument.Course] = []
    
    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rock) {
        self.rockDocument = rock

        setupBindings()
        
        self.rockName = rock.name
        self.rockDesc = rock.desc

        rock.registeredUserReference
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
        $rockName
            .drop(while: { $0.isEmpty })
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                let rockReference = StorageManager.makeReference(
                    parent: FINameSpace.Rocks.self,
                    child: name
                )
                StorageManager.getHeaderReference(reference: rockReference) { [weak self] result in

                    guard let self = self else { return }

                    guard
                        case let .success(reference) = result
                    else {
                        return
                    }
                    
                    self.headerImageReference = reference
                }
            }
            .store(in: &bindings)
    }

    
    
    func fetchCourses() {
        rockDocument.makeDocumentReference()
            .collection(FIDocument.Course.colletionName)
            .getDocuments(FIDocument.Course.self)
            .catch { _ -> Just<[FIDocument.Course]> in
                return .init([])
            }
            .assign(to: &$courses)
    }

}
