//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine

final class CourseDetailViewModel {
    
    @Published var course: FIDocument.Course
    
    private var bindings = Set<AnyCancellable>()
    
    init(course: FIDocument.Course) {
        self.course = course
        setupBindings()
    }
    
    private func setupBindings() {
        
    }
}
