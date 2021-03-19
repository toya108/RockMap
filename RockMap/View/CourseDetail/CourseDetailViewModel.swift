//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine

final class CourseDetailViewModel {
    
    @Published private var course: FIDocument.Course
    @Published var courseImageReferences: [StorageManager.Reference] = []
    @Published var courseName = ""

    private var bindings = Set<AnyCancellable>()
    
    init(course: FIDocument.Course) {
        self.course = course

        setupBindings()
        
        courseName = course.name
    }
    
    private func setupBindings() {
        $courseName
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                let reference = StorageManager.makeReference(
                    parent: FINameSpace.Course.self,
                    child: name
                )
                
                StorageManager.getAllReference(reference: reference) { result in
                    
                    guard
                        case let .success(references) = result
                    else {
                        return
                    }
                    
                    self.courseImageReferences.append(contentsOf: references)
                }
            }
            .store(in: &bindings)
        
    }
}
