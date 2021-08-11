
import Foundation
import FirebaseFirestoreSwift

extension FS.Document {

    struct ClimbRecord: DocumentProtocol, UserRegisterableDocumentProtocol {
        
        var collection: CollectionProtocol.Type { FS.Collection.ClimbRecord.self }

        var id: String = UUID().uuidString
        var registeredUserId: String
        var parentCourseId: String
        var parentCourseReference: FSDocument
        var totalNumberReference: FSDocument
        var createdAt: Date = Date()
        @ExplicitNull var updatedAt: Date?
        var parentPath: String
        var climbedDate: Date
        var type: ClimbedRecordType
    }

}

extension FS.Document.ClimbRecord {

    enum ClimbedRecordType: String, CaseIterable, Codable {
        case flash, redPoint

        var name: String {
            switch self {
                case .flash:
                    return "Flash"
                    
                case .redPoint:
                    return "RedPoint"
                    
            }
        }

        var fieldName: String {
            switch self {
                case .flash:
                    return "flashTotal"

                case .redPoint:
                    return "redPointTotal"

            }
        }

        var isFlash: Bool {
            self == .flash
        }

        var isRedpoint: Bool {
            self == .redPoint
        }
    }
}
