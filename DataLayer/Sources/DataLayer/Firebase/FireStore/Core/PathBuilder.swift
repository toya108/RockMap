import Foundation

@resultBuilder
struct PathBuilder {
    typealias FinalResult = String

    static func buildBlock(_ components: String...) -> [String] {
        components
    }

    static func buildExpression(_ expression: String) -> String {
        expression
    }

    static func buildExpression(_ expression: CollectionProtocol) -> String {
        type(of: expression).name
    }

    static func buildExpression(_ expression: DocumentProtocol) -> String {
        let strings = expression.collection.isRoot
            ? [expression.collection.name, expression.id]
            : [expression.parentPath, expression.collection.name, expression.id]

        return strings.joined(separator: "/")
    }

    static func buildFinalResult(_ component: [String]) -> String {
        component.joined(separator: "/")
    }
}
