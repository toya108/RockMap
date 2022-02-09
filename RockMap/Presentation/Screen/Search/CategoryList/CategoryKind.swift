import SwiftUI

enum CategoryKind: String, CaseIterable, Identifiable {
    case rock
    case course
    case user

    var id: String { self.rawValue }

    var name: LocalizedStringKey {
        switch self {
            case .rock:
                return .init("rock")

            case .course:
                return .init("course")

            case .user:
                return .init("user")
        }
    }

    @ViewBuilder
    var icon: some View {
        switch self {
            case .rock:
                Image(uiImage: Resources.Images.Assets.rockFill.uiImage)
                    .resizable()
                    .frame(width: 24, height: 24)

            case .course:
                let docPlaintextFill = Resources.Images.System.docPlaintextFill.uiImage
                Image(uiImage: docPlaintextFill.withRenderingMode(.alwaysTemplate))
                    .resizable()
                    .frame(width: 16, height: 16)

            case .user:
                Image(uiImage: Resources.Images.System.personFill.uiImage)
                    .resizable()
                    .frame(width: 16, height: 16)
        }
    }
}
