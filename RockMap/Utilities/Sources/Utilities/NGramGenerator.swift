import Foundation

public struct NGramGenerator {

    public static func makeNGram(input: String, n: Int) -> [String] {
        let words = Array(input).map { String($0) }

        return words.enumerated().compactMap { index, _ in
            guard words.indices.contains(index + n - 1) else {
                return nil
            }
            return words[index..<index+n].reduce("", +)
        }
    }

}
