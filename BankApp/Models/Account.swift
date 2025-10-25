import Foundation

struct Account: Identifiable, Hashable {
    enum AccountType: String, CaseIterable {
        case checking = "Checking"
        case savings = "Savings"
        case credit = "Credit"
        case investment = "Investment"
    }

    let id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var number: String
    var transactions: [Transaction]

    var formattedBalance: String {
        NumberFormatter.currency.string(from: balance as NSNumber) ?? "$0.00"
    }

    static let sampleAccounts: [Account] = [
        Account(
            id: UUID(),
            name: "Everyday Checking",
            type: .checking,
            balance: 2543.12,
            number: "•••• 1234",
            transactions: Transaction.sampleTransactions
        ),
        Account(
            id: UUID(),
            name: "High Yield Savings",
            type: .savings,
            balance: 10234.55,
            number: "•••• 5678",
            transactions: Transaction.sampleTransactions.shuffled()
        ),
        Account(
            id: UUID(),
            name: "Rewards Credit",
            type: .credit,
            balance: -342.89,
            number: "•••• 9012",
            transactions: Transaction.sampleTransactions
        )
    ]
}
