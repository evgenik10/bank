import Foundation

struct Card: Identifiable, Hashable {
    enum CardType: String, CaseIterable {
        case debit = "Debit"
        case credit = "Credit"
    }

    let id: UUID
    var nickname: String
    var type: CardType
    var number: String
    var expiration: String
    var isFrozen: Bool
    var spendingLimit: Decimal

    var formattedLimit: String {
        NumberFormatter.currency.string(from: spendingLimit as NSNumber) ?? "$0.00"
    }

    static let sampleCards: [Card] = [
        Card(
            id: UUID(),
            nickname: "Daily Debit",
            type: .debit,
            number: "•••• 4456",
            expiration: "08/26",
            isFrozen: false,
            spendingLimit: 1500
        ),
        Card(
            id: UUID(),
            nickname: "Travel Rewards",
            type: .credit,
            number: "•••• 8899",
            expiration: "01/27",
            isFrozen: false,
            spendingLimit: 5000
        )
    ]
}
