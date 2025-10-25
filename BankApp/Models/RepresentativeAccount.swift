import Foundation

struct RepresentativeAccount: Identifiable, Equatable {
    let id: UUID
    var clientName: String
    var clientEmail: String
    var accounts: [Account]

    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var formattedBalance: String {
        NumberFormatter.currency.string(from: totalBalance as NSNumber) ?? "$0.00"
    }
}
