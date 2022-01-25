import SwiftUI

enum CategoryKind: String, CaseIterable, Identifiable {
    case rock
    case course
    case user

    var id: String { self.rawValue }

    var name: String {
        switch self {
            case .rock:
                return "rock"
            case .course:
                return "course"
            case .user:
                return "user"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
            case .rock:
                RockListView(viewModel: .init())

            case .course:
                CourseListView(viewModel: .init())
                
            case .user:
                Text("user")
        }
    }
}
