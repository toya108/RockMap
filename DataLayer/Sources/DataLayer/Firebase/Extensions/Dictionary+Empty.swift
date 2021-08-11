
import Foundation

extension Dictionary where Key == String, Value == Any {

    func makeEmptyExcludedDictionary () -> [String: Any] {
        return reduce([String: Any]()) { dictionary, element in

            if let stringValue = element.1 as? String, stringValue.isEmpty {
                return dictionary
            }

            var dictionary = dictionary
            dictionary[element.0] = element.1
            return dictionary
        }
    }

}
