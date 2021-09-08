import Foundation

extension Date {
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "ja_JP")
        return formatter
    }

    func string(
        dateStyle: DateFormatter.Style,
        timeStyle: DateFormatter.Style = .none
    ) -> String {
        let formatter = self.formatter
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
