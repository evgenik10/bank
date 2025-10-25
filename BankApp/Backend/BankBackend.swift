import Foundation

enum BackendError: LocalizedError {
    case emailAlreadyUsed
    case invalidCredentials
    case userNotFound
    case notRepresentative
    case accountNotFound
    case cardNotFound
    case verificationRequired
    case invalidVerificationCode
    case invalidRepresentativeCode
    case assignmentNotFound

    var errorDescription: String? {
        switch self {
        case .emailAlreadyUsed:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .userNotFound:
            return "We were unable to locate your profile."
        case .notRepresentative:
            return "Representative tools are unavailable for this profile."
        case .accountNotFound:
            return "One or more accounts could not be found."
        case .cardNotFound:
            return "We can't find a card with that number."
        case .verificationRequired:
            return "Please verify your card before continuing."
        case .invalidVerificationCode:
            return "The SMS code you entered is incorrect."
        case .invalidRepresentativeCode:
            return "The team access code is invalid."
        case .assignmentNotFound:
            return "We couldn't find that delivery assignment."
        }
    }
}

protocol BankBackend {
    func register(name: String, email: String, password: String, role: User.Role, cardNumber: String?, representativeCode: String?) async throws -> User
    func login(email: String, password: String) async throws -> User
    func fetchAccounts(for userID: UUID) async throws -> [Account]
    func fetchCards(for userID: UUID) async throws -> [Card]
    func fetchBudgets(for userID: UUID) async throws -> [Budget]
    func fetchDeliveryAssignments(for representativeID: UUID) async throws -> [CardDeliveryAssignment]
    func performTransfer(amount: Decimal, sourceID: UUID, destinationID: UUID, userID: UUID) async throws -> TransferResult
    func toggleCardFreeze(cardID: UUID, userID: UUID) async throws -> Card
    func requestCardVerification(for cardNumber: String) async throws -> CardholderIdentity
    func confirmCardVerification(cardNumber: String, code: String) async throws -> CardholderIdentity
    func updateDeliveryAssignment(id: UUID, representativeID: UUID, status: CardDeliveryAssignment.Status) async throws -> CardDeliveryAssignment
    func resetDemoData() async
}

actor InMemoryBankBackend: BankBackend {
    static let shared = InMemoryBankBackend()

    private struct StoredUser {
        var user: User
        var password: String
    }

    private struct CardInventoryItem {
        var card: Card
        var holderName: String
        var address: String
    }

    private var usersByEmail: [String: StoredUser] = [:]
    private var accountsByUser: [UUID: [Account]] = [:]
    private var cardsByUser: [UUID: [Card]] = [:]
    private var budgetsByUser: [UUID: [Budget]] = [:]
    private var deliveriesByRepresentative: [UUID: [CardDeliveryAssignment]] = [:]

    private var unassignedCards: [String: CardInventoryItem] = [:]
    private var pendingVerifications: [String: String] = [:]
    private var verifiedCards: Set<String> = []

    private init() {
        seed()
    }

    private let representativeAccessCodes: Set<String> = ["REP-2024"]

    func register(name: String, email: String, password: String, role: User.Role, cardNumber: String?, representativeCode: String?) async throws -> User {
        let normalizedEmail = email.lowercased()
        guard usersByEmail[normalizedEmail] == nil else {
            throw BackendError.emailAlreadyUsed
        }

        var user = User(id: UUID(), name: name, email: normalizedEmail, role: role)
        var storedUser = StoredUser(user: user, password: password)

        switch role {
        case .customer:
            let sanitizedNumber = cardNumber?.filter(\.isNumber) ?? ""
            guard !sanitizedNumber.isEmpty else {
                throw BackendError.verificationRequired
            }
            guard verifiedCards.contains(sanitizedNumber) else {
                throw BackendError.verificationRequired
            }
            guard let inventory = unassignedCards.removeValue(forKey: sanitizedNumber) else {
                throw BackendError.cardNotFound
            }

            verifiedCards.remove(sanitizedNumber)

            var resolvedName = name
            if resolvedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                resolvedName = inventory.holderName
            }
            user.name = resolvedName
            storedUser.user = user

            accountsByUser[user.id] = Self.generateAccounts(for: user)
            cardsByUser[user.id] = [inventory.card]
            budgetsByUser[user.id] = Budget.sampleBudgets

        case .representative:
            let normalizedCode = representativeCode?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
            guard representativeAccessCodes.contains(normalizedCode) else {
                throw BackendError.invalidRepresentativeCode
            }
            accountsByUser[user.id] = []
            cardsByUser[user.id] = []
            budgetsByUser[user.id] = []
            deliveriesByRepresentative[user.id] = []
        }

        usersByEmail[normalizedEmail] = storedUser

        return user
    }

    func login(email: String, password: String) async throws -> User {
        guard let stored = usersByEmail[email.lowercased()], stored.password == password else {
            throw BackendError.invalidCredentials
        }
        return stored.user
    }

    func fetchAccounts(for userID: UUID) async throws -> [Account] {
        guard let accounts = accountsByUser[userID] else {
            throw BackendError.userNotFound
        }
        return accounts
    }

    func fetchCards(for userID: UUID) async throws -> [Card] {
        guard let cards = cardsByUser[userID] else {
            throw BackendError.userNotFound
        }
        return cards
    }

    func fetchBudgets(for userID: UUID) async throws -> [Budget] {
        guard let budgets = budgetsByUser[userID] else {
            throw BackendError.userNotFound
        }
        return budgets
    }

    func fetchDeliveryAssignments(for representativeID: UUID) async throws -> [CardDeliveryAssignment] {
        guard let assignments = deliveriesByRepresentative[representativeID] else {
            throw BackendError.notRepresentative
        }
        return sortedAssignments(assignments)
    }

    func performTransfer(amount: Decimal, sourceID: UUID, destinationID: UUID, userID: UUID) async throws -> TransferResult {
        guard var accounts = accountsByUser[userID] else {
            throw BackendError.userNotFound
        }
        guard let sourceIndex = accounts.firstIndex(where: { $0.id == sourceID }),
              let destinationIndex = accounts.firstIndex(where: { $0.id == destinationID }) else {
            throw BackendError.accountNotFound
        }
        guard accounts[sourceIndex].balance >= amount else {
            return TransferResult(success: false, message: "Insufficient funds")
        }

        accounts[sourceIndex].balance -= amount
        accounts[destinationIndex].balance += amount
        accountsByUser[userID] = accounts
        return TransferResult(success: true, message: "Transfer complete")
    }

    func toggleCardFreeze(cardID: UUID, userID: UUID) async throws -> Card {
        guard var cards = cardsByUser[userID],
              let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw BackendError.accountNotFound
        }
        cards[index].isFrozen.toggle()
        cardsByUser[userID] = cards
        return cards[index]
    }

    func requestCardVerification(for cardNumber: String) async throws -> CardholderIdentity {
        let sanitized = cardNumber.filter(\.isNumber)
        guard !sanitized.isEmpty else { throw BackendError.cardNotFound }
        guard let inventory = unassignedCards[sanitized] else {
            throw BackendError.cardNotFound
        }

        let code = String(format: "%06d", Int.random(in: 10_000...99_999))
        pendingVerifications[sanitized] = code
        return CardholderIdentity(name: inventory.holderName, maskedNumber: inventory.card.maskedNumber, demoCode: code)
    }

    func confirmCardVerification(cardNumber: String, code: String) async throws -> CardholderIdentity {
        let sanitized = cardNumber.filter(\.isNumber)
        guard let expected = pendingVerifications[sanitized], expected == code else {
            throw BackendError.invalidVerificationCode
        }
        guard let inventory = unassignedCards[sanitized] else {
            throw BackendError.cardNotFound
        }

        pendingVerifications.removeValue(forKey: sanitized)
        verifiedCards.insert(sanitized)
        return CardholderIdentity(name: inventory.holderName, maskedNumber: inventory.card.maskedNumber, demoCode: nil)
    }

    func updateDeliveryAssignment(id: UUID, representativeID: UUID, status: CardDeliveryAssignment.Status) async throws -> CardDeliveryAssignment {
        guard var assignments = deliveriesByRepresentative[representativeID] else {
            throw BackendError.notRepresentative
        }
        guard let index = assignments.firstIndex(where: { $0.id == id }) else {
            throw BackendError.assignmentNotFound
        }

        var assignment = assignments[index]
        guard assignment.status.canTransition(to: status) else {
            return assignment
        }

        assignment.status = status
        assignments[index] = assignment
        let resorted = sortedAssignments(assignments)
        deliveriesByRepresentative[representativeID] = resorted
        return assignment
    }

    func resetDemoData() async {
        usersByEmail = [:]
        accountsByUser = [:]
        cardsByUser = [:]
        budgetsByUser = [:]
        deliveriesByRepresentative = [:]
        unassignedCards = [:]
        pendingVerifications = [:]
        verifiedCards = []
        seed()
    }

    private func seed() {
        let primaryUser = User.mockCustomer
        let representative = User.mockRepresentative
        usersByEmail[primaryUser.email] = StoredUser(user: primaryUser, password: "password")
        usersByEmail[representative.email] = StoredUser(user: representative, password: "password")

        accountsByUser[primaryUser.id] = Account.sampleAccounts
        cardsByUser[primaryUser.id] = Card.sampleCards
        budgetsByUser[primaryUser.id] = Budget.sampleBudgets

        accountsByUser[representative.id] = []
        cardsByUser[representative.id] = []
        budgetsByUser[representative.id] = []
        deliveriesByRepresentative[representative.id] = sortedAssignments(.sampleAssignments)

        let availableCards: [CardInventoryItem] = [
            CardInventoryItem(
                card: Card(
                    id: UUID(),
                    nickname: "Sapphire Debit",
                    type: .debit,
                    number: "5244123412345555",
                    expiration: "09/28",
                    isFrozen: false,
                    spendingLimit: 2000
                ),
                holderName: "Sasha Bright",
                address: "18 Liberty Street"
            ),
            CardInventoryItem(
                card: Card(
                    id: UUID(),
                    nickname: "Infinity Credit",
                    type: .credit,
                    number: "4788987612345678",
                    expiration: "03/29",
                    isFrozen: false,
                    spendingLimit: 7000
                ),
                holderName: "Jamie Fox",
                address: "92 Sunset Road"
            )
        ]

        for item in availableCards {
            let sanitized = item.card.number.filter(\.isNumber)
            unassignedCards[sanitized] = item
        }
    }

    private static func generateAccounts(for user: User) -> [Account] {
        Account.sampleAccounts.map { account in
            var copy = account
            copy.name = account.name.replacingOccurrences(of: "Everyday", with: user.name.split(separator: " ").first.map(String.init) ?? "Primary")
            return copy
        }
    }

    private func sortedAssignments(_ assignments: [CardDeliveryAssignment]) -> [CardDeliveryAssignment] {
        assignments.sorted { lhs, rhs in
            if lhs.status.sortPriority != rhs.status.sortPriority {
                return lhs.status.sortPriority < rhs.status.sortPriority
            }
            return lhs.scheduledDate < rhs.scheduledDate
        }
    }
}
