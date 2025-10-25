import Foundation

struct Transaction: Identifiable, Hashable {
    enum Category: String, CaseIterable {
        case groceries = "Groceries"
        case dining = "Dining"
        case transport = "Transport"
        case entertainment = "Entertainment"
        case utilities = "Utilities"
        case deposit = "Deposit"
    }

    let id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var category: Category
    var isDebit: Bool

    var formattedAmount: String {
        let value = isDebit ? -amount : amount
        return NumberFormatter.currency.string(from: value as NSNumber) ?? "$0.00"
    }

    var formattedDate: String {
        DateFormatter.transaction.string(from: date)
    }

    static let sampleTransactions: [Transaction] = [
        Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 1),
            description: "Trader Joe's",
            amount: 52.34,
            category: .groceries,
            isDebit: true
        ),
        Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 2),
            description: "Payroll",
            amount: 2500.00,
            category: .deposit,
            isDebit: false
        ),
        Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 3),
            description: "Uber",
            amount: 18.45,
            category: .transport,
            isDebit: true
        ),
        Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 5),
            description: "Netflix",
            amount: 15.99,
            category: .entertainment,
            isDebit: true
        )
    ]
}
