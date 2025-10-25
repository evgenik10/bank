import Foundation

struct CardDeliveryAssignment: Identifiable, Hashable {
    enum Status: String {
        case scheduled
        case enRoute
        case delivered

        var nextStatus: Status? {
            switch self {
            case .scheduled: return .enRoute
            case .enRoute: return .delivered
            case .delivered: return nil
            }
        }

        var actionTitle: String {
            switch self {
            case .scheduled: return "Start route"
            case .enRoute: return "Mark delivered"
            case .delivered: return "Completed"
            }
        }

        var sortPriority: Int {
            switch self {
            case .enRoute: return 0
            case .scheduled: return 1
            case .delivered: return 2
            }
        }

        var progressIndex: Int {
            switch self {
            case .scheduled: return 0
            case .enRoute: return 1
            case .delivered: return 2
            }
        }

        func canTransition(to newValue: Status) -> Bool {
            switch (self, newValue) {
            case (.scheduled, .enRoute), (.enRoute, .delivered):
                return true
            default:
                return self == newValue
            }
        }
    }

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
