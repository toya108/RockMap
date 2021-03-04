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
    
    @Published var imageUploadState: StorageUploader.UploadState = .stanby
    @Published var rockUploadState: StoreUploadState = .stanby
    
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
    }
    
}
