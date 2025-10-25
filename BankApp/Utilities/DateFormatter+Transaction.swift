import Foundation

extension DateFormatter {
    static let transaction: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
