import Foundation

protocol BankServicing {
    var user: User { get }
    func fetchAccounts() async throws -> [Account]
    func fetchCards() async throws -> [Card]
    func fetchBudgets() async throws -> [Budget]
    func fetchRepresentativeAccounts() async throws -> [RepresentativeAccount]
    func performTransfer(amount: Decimal, from source: Account, to destination: Account) async throws -> TransferResult
    func toggleCardFreeze(_ card: Card) async throws -> Card
}

struct TransferResult {
    var success: Bool
    var message: String
}

final class MockBankService: BankServicing {
    let user: User
    private var accounts: [Account]
    private var cards: [Card]
    private var budgets: [Budget]

    init(user: User = .mockCustomer,
         accounts: [Account] = Account.sampleAccounts,
         cards: [Card] = Card.sampleCards,
         budgets: [Budget] = Budget.sampleBudgets) {
        self.user = user
        self.accounts = accounts
        self.cards = cards
        self.budgets = budgets
    }

    func fetchAccounts() async throws -> [Account] {
        accounts
    }

    func fetchCards() async throws -> [Card] {
        cards
    }

    func fetchBudgets() async throws -> [Budget] {
        budgets
    }

    func fetchRepresentativeAccounts() async throws -> [RepresentativeAccount] {
        []
    }

    func performTransfer(amount: Decimal, from source: Account, to destination: Account) async throws -> TransferResult {
        guard let sourceIndex = accounts.firstIndex(of: source),
              let destinationIndex = accounts.firstIndex(of: destination) else {
            return TransferResult(success: false, message: "Accounts not found")
        }

        guard accounts[sourceIndex].balance >= amount else {
            return TransferResult(success: false, message: "Insufficient funds")
        }

        accounts[sourceIndex].balance -= amount
        accounts[destinationIndex].balance += amount

        return TransferResult(success: true, message: "Transfer successful")
    }

    func toggleCardFreeze(_ card: Card) async throws -> Card {
        guard let index = cards.firstIndex(of: card) else { return card }
        cards[index].isFrozen.toggle()
        return cards[index]
    }
}
