import Foundation

enum BackendError: LocalizedError {
    case emailAlreadyUsed
    case invalidCredentials
    case userNotFound
    case notRepresentative
    case accountNotFound

    var errorDescription: String? {
        switch self {
        case .emailAlreadyUsed:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .userNotFound:
            return "We were unable to locate your profile."
        case .notRepresentative:
            return "Representative data is unavailable for this profile."
        case .accountNotFound:
            return "One or more accounts could not be found."
        }
    }
}

protocol BankBackend {
    func register(name: String, email: String, password: String, role: User.Role) async throws -> User
    func login(email: String, password: String) async throws -> User
    func fetchAccounts(for userID: UUID) async throws -> [Account]
    func fetchCards(for userID: UUID) async throws -> [Card]
    func fetchBudgets(for userID: UUID) async throws -> [Budget]
    func fetchRepresentativeAccounts(for representativeID: UUID) async throws -> [RepresentativeAccount]
    func performTransfer(amount: Decimal, sourceID: UUID, destinationID: UUID, userID: UUID) async throws -> TransferResult
    func toggleCardFreeze(cardID: UUID, userID: UUID) async throws -> Card
}

actor InMemoryBankBackend: BankBackend {
    static let shared = InMemoryBankBackend()

    private struct StoredUser {
        var user: User
        var password: String
    }

    private var usersByEmail: [String: StoredUser] = [:]
    private var accountsByUser: [UUID: [Account]] = [:]
    private var cardsByUser: [UUID: [Card]] = [:]
    private var budgetsByUser: [UUID: [Budget]] = [:]
    private var representativeMappings: [UUID: [UUID]] = [:]

    private init() {
        seed()
    }

    func register(name: String, email: String, password: String, role: User.Role) async throws -> User {
        guard usersByEmail[email.lowercased()] == nil else {
            throw BackendError.emailAlreadyUsed
        }

        let user = User(id: UUID(), name: name, email: email.lowercased(), role: role)
        usersByEmail[email.lowercased()] = StoredUser(user: user, password: password)
        accountsByUser[user.id] = role == .customer ? Self.generateAccounts(for: user) : []
        cardsByUser[user.id] = role == .customer ? Self.generateCards() : []
        budgetsByUser[user.id] = role == .customer ? Budget.sampleBudgets : []
        if role == .representative {
            representativeMappings[user.id] = []
        } else if let representativeID = representativeMappings.keys.first {
            representativeMappings[representativeID, default: []].append(user.id)
        }

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

    func fetchRepresentativeAccounts(for representativeID: UUID) async throws -> [RepresentativeAccount] {
        guard let clientIDs = representativeMappings[representativeID] else {
            throw BackendError.notRepresentative
        }

        return clientIDs.compactMap { clientID in
            guard let stored = accountsByUser[clientID],
                  let user = usersByEmail.first(where: { $0.value.user.id == clientID })?.value.user else {
                return nil
            }
            return RepresentativeAccount(id: clientID, clientName: user.name, clientEmail: user.email, accounts: stored)
        }
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

        representativeMappings[representative.id] = [primaryUser.id]
    }

    private static func generateAccounts(for user: User) -> [Account] {
        Account.sampleAccounts.map { account in
            var copy = account
            copy.name = account.name.replacingOccurrences(of: "Everyday", with: user.name.split(separator: " ").first.map(String.init) ?? "Primary")
            return copy
        }
    }

    private static func generateCards() -> [Card] {
        Card.sampleCards.map { card in
            var copy = card
            copy.nickname = card.nickname
            return copy
        }
    }
}
