import Foundation

struct CardDeliveryAssignment: Identifiable, Hashable {
    enum Status: String { case scheduled, enRoute, delivered }

    let id: UUID
    var clientName: String
    var address: String
    var scheduledDate: Date
    var cardNickname: String
    var status: Status

    var formattedDate: String {
        DateFormatter.cardDelivery.string(from: scheduledDate)
    }
}

extension Array where Element == CardDeliveryAssignment {
    static let sampleAssignments: [CardDeliveryAssignment] = [
        CardDeliveryAssignment(
            id: UUID(),
            clientName: "Taylor James",
            address: "45 Seaside Avenue",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now,
            cardNickname: "Daily Debit",
            status: .scheduled
        ),
        CardDeliveryAssignment(
            id: UUID(),
            clientName: "Avery Stone",
            address: "22 Hillcrest Blvd",
            scheduledDate: Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now,
            cardNickname: "Travel Rewards",
            status: .enRoute
        ),
        CardDeliveryAssignment(
            id: UUID(),
            clientName: "Morgan Finch",
            address: "5 Harbor Row",
            scheduledDate: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            cardNickname: "Sapphire Debit",
            status: .delivered
        )
    ]
}
