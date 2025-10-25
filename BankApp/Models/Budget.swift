import Foundation

struct Budget: Identifiable, Hashable {
    let id: UUID
    var category: Transaction.Category
    var limit: Decimal
    var spent: Decimal

    var progress: Double {
        guard limit > 0 else { return 0 }
        return min(Double(truncating: spent as NSNumber) / Double(truncating: limit as NSNumber), 1.0)
    }

    var formattedLimit: String {
        NumberFormatter.currency.string(from: limit as NSNumber) ?? "$0.00"
    }

    var formattedSpent: String {
        NumberFormatter.currency.string(from: spent as NSNumber) ?? "$0.00"
    }

    static let sampleBudgets: [Budget] = [
        Budget(id: UUID(), category: .groceries, limit: 600, spent: 420),
        Budget(id: UUID(), category: .dining, limit: 300, spent: 180),
        Budget(id: UUID(), category: .entertainment, limit: 200, spent: 75)
    ]
}
