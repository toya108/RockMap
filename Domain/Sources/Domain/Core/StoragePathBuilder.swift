import Foundation

@resultBuilder
public struct StoragePathBuilder {
    typealias FinalResult = String

    public static func buildBlock(_ components: String...) -> [String] {
        components
    }

    public static func buildExpression(_ expression: String) -> String {
        expression
    }

    public static func buildExpression(_ expression: ImageDestination) -> String {
        expression.name
    }

    public static func buildExpression(_ expression: Domain.Entity.Image.ImageType) -> String {
        expression.name
    }

    public static func buildFinalResult(_ component: [String]) -> String {
        (component + [UUID().uuidString]).joined(separator: "/")
    }
}
