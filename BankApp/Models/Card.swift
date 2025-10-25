import Foundation

struct Card: Identifiable, Hashable {
    enum CardType: String, CaseIterable {
        case debit = "Debit"
        case credit = "Credit"
    }

    let id: UUID
    var nickname: String
    var type: CardType
    /// Full primary account number with digits only
    var number: String
    var expiration: String
    var isFrozen: Bool
    var spendingLimit: Decimal

    var formattedLimit: String {
        NumberFormatter.currency.string(from: spendingLimit as NSNumber) ?? "$0.00"
    }

    var maskedNumber: String {
        let digits = number.filter(\.isNumber)
        guard digits.count >= 4 else { return number }
        let suffix = digits.suffix(4)
        return "•••• \(suffix)"
    }

    var formattedNumber: String {
        let digits = number.filter(\.isNumber)
        guard !digits.isEmpty else { return number }
        var groups: [String] = []
        var current = ""
        for char in digits {
            current.append(char)
            if current.count == 4 {
                groups.append(current)
                current = ""
            }
        }
        if !current.isEmpty { groups.append(current) }
        return groups.joined(separator: " ")
    }

    static let sampleCards: [Card] = [
        Card(
            id: UUID(),
            nickname: "Daily Debit",
            type: .debit,
            number: "4456123412341234",
            expiration: "08/26",
            isFrozen: false,
            spendingLimit: 1500
        ),
        Card(
            id: UUID(),
            nickname: "Travel Rewards",
            type: .credit,
            number: "8899123411112222",
            expiration: "01/27",
            isFrozen: false,
            spendingLimit: 5000
        )
    ]
}
