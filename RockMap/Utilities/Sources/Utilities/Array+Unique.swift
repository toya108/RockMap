import Foundation

public extension Array where Element: Hashable {
    var unique: [Element] {
        self.reduce([]) {
            $0.contains($1)
                ? $0
                : $0 + [$1]
        }
    }
}
