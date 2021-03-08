//
//  CourseConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Combine
import Foundation

class CourseConfirmViewModel {
    
    let rock: CourseRegisterViewModel.RockHeaderStructure
    let courseName: String
    let grade: FIDocument.Course.Grade
    let images: [IdentifiableData]
    let desc: String
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var courseUploadState: StoreUploadState = .stanby
    @Published private(set) var addIdState: StoreUploadState = .stanby
    
    private let uploader = StorageUploader()
    
    init(
        rock: CourseRegisterViewModel.RockHeaderStructure,
        courseName: String,
        grade: FIDocument.Course.Grade,
        images: [IdentifiableData],
        desc: String
    ) {
        self.rock = rock
        self.courseName = courseName
        self.grade = grade
        self.images = images
        self.desc = desc
        
        bindImageUploader()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &$imageUploadState)
    }
    
    func uploadImages() {
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: courseName
        )
        images.forEach {
            let imageReference = reference.child(UUID().uuidString)
            uploader.addData(data: $0.data, reference: imageReference)
        }
        uploader.start()
    }
    
    func registerCourse() {
        
        courseUploadState = .loading
        
        let courseDocument = FIDocument.Course(
            id: UUID().uuidString,
            name: courseName,
            desc: desc,
            grade: grade,
            climbedUserIdList: [],
            registedUserId: AuthManager.uid,
            registeredDate: Date()
        )
        
//        addCourceIdToRock(courceId: courseDocument.id)
        
        FirestoreManager.set(
            key: courseDocument.id,
            courseDocument
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.courseUploadState = .finish
                
            case .failure(let error):
                self.courseUploadState = .failure(error)
                
            }
        }
    }
//    
//    private func addCourceIdToRock(courceId: String) {
//        
//        FirestoreManager.fetchById(id: rock.rockId) { (result: Result<FIDocument.Rock?, Error>) in
//            
//            switch result {
//            case .success(let rockDocument):
//                
//                guard
//                    var rockDocument = rockDocument
//                else {
//                    return
//                }
//                
//                rockDocument.courseId.append(courceId)
//                
//                FirestoreManager.set(
//                    key: rockDocument.id,
//                    rockDocument
//                ) { _ in }
//                
//            case .failure:
//                break
//            }
//        
//        }
//    }
}
