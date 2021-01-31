//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel {
    
    @Published private var rockDocument: FIDocument.Rocks = .init()
    
    @Published var rockName = ""
    @Published var registerdUserId = ""
    @Published var registeredUserName = ""
    @Published var userIcon = ""
    @Published var rockDesc = ""
    @Published var rockImageReferences: [StorageManager.Reference] = []
    
    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rocks) {
        setupBindings()

        self.rockDocument = rock
    }
    
    private func setupBindings() {
        $rockDocument
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.rockName = rock.name
                self.rockDesc = rock.desc
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
    }
}

