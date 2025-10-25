import Foundation

final class BackendBankService: BankServicing {
    let user: User
    private let backend: BankBackend

    init(user: User, backend: BankBackend) {
        self.user = user
        self.backend = backend
    }

    func fetchAccounts() async throws -> [Account] {
        try await backend.fetchAccounts(for: user.id)
    }

    func fetchCards() async throws -> [Card] {
        try await backend.fetchCards(for: user.id)
    }

    func fetchBudgets() async throws -> [Budget] {
        try await backend.fetchBudgets(for: user.id)
    }

    func fetchRepresentativeAccounts() async throws -> [RepresentativeAccount] {
        try await backend.fetchRepresentativeAccounts(for: user.id)
    }

    func performTransfer(amount: Decimal, from source: Account, to destination: Account) async throws -> TransferResult {
        try await backend.performTransfer(amount: amount, sourceID: source.id, destinationID: destination.id, userID: user.id)
    }

    func toggleCardFreeze(_ card: Card) async throws -> Card {
        try await backend.toggleCardFreeze(cardID: card.id, userID: user.id)
    }
}
