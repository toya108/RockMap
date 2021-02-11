//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel {
    
    @Published var rockDocument: FIDocument.Rocks = .init()
    @Published var rockName = ""
    @Published var registeredUserId = ""
    @Published var registeredUser: FIDocument.Users = .init()
    @Published var rockDesc = ""
    @Published var rockLocation: RockLocation = .init()
    @Published var rockImageReferences: [StorageManager.Reference] = []
    @Published var courseIdList: [String] = []
    
    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rocks) {
        setupBindings()
        self.rockDocument = rock
    }
    
    private func setupBindings() {
        $rockDocument
            .dropFirst()
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.rockName = rock.name
                self.rockDesc = rock.desc
                self.registeredUserId = rock.registeredUserId
                self.rockLocation = .init(
                    latitude: rock.location.latitude,
                    longitude: rock.location.longitude,
                    address: rock.address
                )
                self.courseIdList = rock.courseId
            }
            .store(in: &bindings)
        
        $rockName
            .flatMap { name -> Future<[StorageManager.Reference], Error> in
                
                let reference = StorageManager.makeReference(
                    parent: FINameSpace.Rocks.self,
                    child: name
                )
                
                return StorageManager.getAllReference(reference: reference)
            }
            .eraseToAnyPublisher()
            .replaceError(with: [])
            .assign(to: &$rockImageReferences)
        
        $registeredUserId
            .sink { id in
                FirestoreManager.fetchById(id: id) { [weak self] (result: Result<FIDocument.Users?, Error>) in
                    
                    guard
                        let self = self,
                        case let .success(user) = result,
                        let unwrappedUser = user
                    else {
                        return
                    }
                    
                    self.registeredUser = unwrappedUser
                }
            }
            .store(in: &bindings)
    }
    
    struct RockLocation: Hashable {
        var latitude: Double = 0
        var longitude: Double = 0
        var address: String = ""
    }
}

