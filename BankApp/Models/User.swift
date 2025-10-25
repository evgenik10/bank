import Foundation

struct User: Identifiable, Equatable {
    enum Role: String, CaseIterable {
        case customer
        case representative

        var displayName: String {
            switch self {
            case .customer:
                return "Customer"
            case .representative:
                return "Representative"
            }
        }
    }

    let id: UUID
    var name: String
    var email: String
    var role: Role
}

extension User {
    static let mockCustomer = User(id: UUID(), name: "Jordan Rivers", email: "jordan@bank.app", role: .customer)
    static let mockRepresentative = User(id: UUID(), name: "Morgan Lee", email: "morgan@bank.app", role: .representative)
}
